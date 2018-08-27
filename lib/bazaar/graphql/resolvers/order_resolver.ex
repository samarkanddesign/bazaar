defmodule Bazaar.GraphQl.Resolvers.OrderResolver do
  alias Bazaar.Order

  alias Bazaar.OrderItem
  alias Bazaar.Basket
  alias Bazaar.Repo
  alias Stripe

  def place_order(_root, args, %{
        context: %{current_user: %{id: user_id, billing_token: billing_token}}
      }) do
    case Repo.get(Basket, args.basket_id) |> Repo.preload(basket_items: :product) do
      %{basket_items: items} ->
        case Order.changeset(
               %Order{
                 user_id: user_id,
                 status: "pending",
                 order_items: order_items_from_basket_items(items)
               },
               %{
                 shipping_address_id: args.shipping_address_id
               }
             )
             |> Repo.insert() do
          {:ok, order} ->
            case Stripe.Charge.create(%{
                   customer: billing_token,
                   currency: "gbp",
                   amount: order_total(order),
                   source: args.card_id,
                   description: "Order #{order.id}"
                 }) do
              {:ok, charge} ->
                Task.start(Bazaar.Services.StockKeeper, :update_stock, [order])

                {:ok,
                 %{
                   status: "ok",
                   order:
                     Repo.update!(
                       Order.changeset(order, %{status: "processing", payment_id: charge.id})
                     )
                 }}

              err ->
                err
            end

          _ ->
            {:error, "Invalid arguments. Address probably does not exist"}
        end

      _ ->
        {:error, "basket does not exist"}
    end
  end

  def place_order(_root, _args, _info) do
    {:error, "Not authenticated"}
  end

  defp order_items_from_basket_items(items) do
    items
    |> Enum.map(fn item ->
      %OrderItem{
        product_id: item.product_id,
        price_paid: Bazaar.Product.payable_price(item.product),
        description: item.product.name,
        quantity: item.quantity
      }
    end)
  end

  defp order_total(%Order{order_items: items}) do
    Enum.reduce(items, 0, fn %OrderItem{price_paid: price_paid}, total -> total + price_paid end)
  end
end
