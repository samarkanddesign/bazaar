defmodule Bazaar.GraphQl.Resolvers.OrderResolver do
  alias Bazaar.Order

  alias Bazaar.OrderItem
  alias Bazaar.Basket
  alias Bazaar.Repo

  def place_order(_root, args, %{context: %{current_user: user}}) do
    %{basket_items: items} =
      Repo.get!(Basket, args.basket_id) |> Repo.preload(basket_items: :product)

    order_items =
      items
      |> Enum.map(fn item ->
        %OrderItem{
          product_id: item.product_id,
          price_paid: item.product.price,
          description: item.product.name
        }
      end)

    order =
      %Order{
        user_id: user.id,
        status: "pending",
        shipping_address_id: args.shipping_address_id,
        billing_address_id: args.billing_address_id,
        order_items: order_items
      }
      |> Repo.insert!()

    {:ok, %{status: "ok", order: order}}
  end

  def place_order(_root, _args, _info) do
    {:error, "Invalid"}
  end
end
