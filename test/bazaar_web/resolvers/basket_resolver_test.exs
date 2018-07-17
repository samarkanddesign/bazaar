defmodule BazaarWeb.BasketResolverTest do
  use BazaarWeb.ConnCase
  alias Bazaar.Repo
  import Bazaar.Factory
  alias Bazaar.GraphQl.Resolvers.BasketResolver

  test "Adding a product to a non-existent basket" do
    product = insert(:product)

    {status, basket} =
      BasketResolver.add_item_to_basket(
        "",
        %{product_id: product.id, quantity: 1, basket_id: "abc123"},
        ""
      )

    assert status == :ok
    assert basket |> get_basket_items |> Enum.count() == 1
    assert basket.basket_id == "abc123"
  end

  test "Adding a product to a basket that already contains a different product" do
    basket_item = insert(:basket_item)

    product = insert(:product)

    {status, basket} =
      BasketResolver.add_item_to_basket(
        "",
        %{product_id: product.id, quantity: 1, basket_id: basket_item.basket.basket_id},
        ""
      )

    assert status == :ok
    assert basket |> Repo.preload(:basket_items) |> Map.get(:basket_items) |> Enum.count() == 2
  end

  test "Adding a non-existant product to a basket" do
    {status, message} =
      BasketResolver.add_item_to_basket(
        "",
        %{product_id: 99, quantity: 1, basket_id: "abc1234"},
        ""
      )

    assert status == :error
    assert is_bitstring(message)
  end

  test "Adding more items to basket than are in stock" do
    product = insert(:product, %{stock_qty: 2})

    {status, message} =
      BasketResolver.add_item_to_basket(
        "",
        %{
          product_id: product.id,
          quantity: 3,
          basket_id: "abc12345"
        },
        ""
      )

    assert status == :error
    assert message == "There is not enough stock to add this to the basket"
  end

  test "Removing a product from the basket that is in the basket" do
    basket_item = insert(:basket_item) |> Repo.preload(:basket)

    {status, basket} =
      BasketResolver.remove_item_from_basket(
        "",
        %{
          basket_id: basket_item.basket.basket_id,
          item_id: basket_item.id
        },
        ""
      )

    assert status == :ok
    assert basket |> get_basket_items |> Enum.count() == 0
  end

  defp get_basket_items(basket) do
    basket |> Repo.preload(:basket_items) |> Map.get(:basket_items)
  end
end
