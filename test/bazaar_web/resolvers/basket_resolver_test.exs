defmodule BazaarWeb.BasketResolverTest do
  use BazaarWeb.ConnCase

  import Bazaar.Factory

  alias Bazaar.Repo
  alias Bazaar.AbsintheHelpers
  alias Bazaar.Basket
  alias Bazaar.GraphQl.Resolvers.BasketResolver

  describe "Basker Resolver" do
    test "creating a new basket", context do
      mutation =
        """
          mutation {
            createBasket {
              id
            }
          }
        """
        |> AbsintheHelpers.mutation_skeleton()

      res =
        context.conn
        |> post("/graphql", mutation)
        |> json_response(200)

      assert res["data"]["createBasket"]["id"] |> String.slice(13..14) == "-4"
    end

    test "adding a product to an empty basket", context do
      product = insert(:product)
      basket = insert(:basket)

      mutation =
        """
        mutation {
          addProductToBasket(basketId:"#{basket.id}", productId:#{product.id}, quantity:1) {
            id
            items {
              id
            }
          }
        }
        """
        |> AbsintheHelpers.mutation_skeleton()

      res =
        context.conn
        |> post("/graphql", mutation)
        |> json_response(200)

      assert res["data"]["addProductToBasket"]["items"] |> Enum.count() == 1
      assert basket |> Repo.preload(:basket_items) |> Map.get(:basket_items) |> Enum.count() == 1
    end

    test "adding a product to a non-existent basket", context do
      product = insert(:product)

      mutation =
        """
        mutation {
          addProductToBasket(basketId:"#{Ecto.UUID.generate()}", productId:#{product.id}, quantity:1) {
            id
            items {
              id
            }
          }
        }
        """
        |> AbsintheHelpers.mutation_skeleton()

      res =
        context.conn
        |> post("/graphql", mutation)
        |> json_response(200)

      error_message = List.first(res["errors"])["message"]
      assert error_message == "basket does not exist"
    end

    test "Adding a product to a basket that already contains a different product", context do
      basket_item = insert(:basket_item)

      product = insert(:product)

      mutation =
        """
        mutation {
          addProductToBasket(basketId:"#{basket_item.basket_id}", productId:#{product.id}, quantity:1) {
            id
            items {
              id
            }
          }
        }
        """
        |> AbsintheHelpers.mutation_skeleton()

      res =
        context.conn
        |> post("/graphql", mutation)
        |> json_response(200)

      assert res["data"]["addProductToBasket"]["items"] |> Enum.count() == 2

      assert Repo.get(Basket, basket_item.basket_id)
             |> Repo.preload(:basket_items)
             |> Map.get(:basket_items)
             |> Enum.count() == 2
    end
  end

  test "Adding a non-existant product to a basket" do
    {status, message} =
      BasketResolver.add_item_to_basket(
        "",
        %{product_id: 99, quantity: 1, basket_id: "abc1234"},
        ""
      )

    assert status == :error
    assert String.contains?(message, "Cannot add product to basket")
  end

  test "Adding more items to basket than are in stock" do
    product = insert(:product, %{stock_qty: 2})
    basket = insert(:basket)

    {status, message} =
      BasketResolver.add_item_to_basket(
        "",
        %{
          product_id: product.id,
          quantity: 3,
          basket_id: basket.id
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
          basket_id: basket_item.basket_id,
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
