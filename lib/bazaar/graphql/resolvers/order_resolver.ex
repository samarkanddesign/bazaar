defmodule Bazaar.GraphQl.Resolvers.OrderResolver do
  alias Bazaar.Order

  alias Bazaar.OrderItem
  alias Bazaar.Basket
  alias Bazaar.Repo

  def place_order(_root, args, %{context: %{current_user: user}}) do
    case Repo.get(Basket, args.basket_id) |> Repo.preload(basket_items: :product) do
      %{basket_items: items} ->
        case Order.changeset(
               %Order{
                 user_id: user.id,
                 status: "pending",
                 order_items: order_items_from_basket_items(items)
               },
               %{
                 shipping_address_id: args.shipping_address_id,
                 billing_address_id: args.billing_address_id
               }
             )
             |> Repo.insert() do
          {:ok, order} -> {:ok, %{status: "ok", order: order}}
          err -> err
        end

      _ ->
        {:error, "basket does not exist"}
    end
  end

  def place_order(_root, _args, _info) do
    {:error, "Invalid"}
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
end
