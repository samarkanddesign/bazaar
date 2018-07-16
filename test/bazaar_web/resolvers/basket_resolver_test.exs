defmodule BazaarWeb.BasketResolverTest do
  use BazaarWeb.ConnCase

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
    assert Enum.count(basket.basket_items) == 1
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
    assert Enum.count(basket.basket_items) == 2
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
end
