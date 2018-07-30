defmodule BazaarWeb.BasketResolverTest do
  use BazaarWeb.ConnCase

  import Bazaar.Factory

  alias Bazaar.Repo
  alias Bazaar.AbsintheHelpers
  alias Bazaar.Basket

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

      mutation = add_to_basket_mutation(basket.id, product.id)
      res = make_mutation(context.conn, mutation)

      assert res["data"]["addProductToBasket"]["items"] |> Enum.count() == 1
      assert basket |> Repo.preload(:basket_items) |> Map.get(:basket_items) |> Enum.count() == 1
    end

    test "adding a product to a non-existent basket", context do
      product = insert(:product)

      mutation = add_to_basket_mutation(Ecto.UUID.generate(), product.id)
      res = make_mutation(context.conn, mutation)

      error_message = List.first(res["errors"])["message"]
      assert error_message == "basket does not exist"
    end

    test "Adding a product to a basket that already contains a different product", context do
      basket_item = insert(:basket_item)

      product = insert(:product)

      mutation = add_to_basket_mutation(basket_item.basket_id, product.id)

      res = make_mutation(context.conn, mutation)

      assert res["data"]["addProductToBasket"]["items"] |> Enum.count() == 2

      assert Repo.get(Basket, basket_item.basket_id)
             |> Repo.preload(:basket_items)
             |> Map.get(:basket_items)
             |> Enum.count() == 2
    end

    test "Adding a non-existant product to a basket", context do
      basket = insert(:basket)
      mutation = add_to_basket_mutation(basket.id, 9999)

      res = make_mutation(context.conn, mutation)

      assert List.first(res["errors"])["message"]
             |> String.contains?("Cannot add product to basket")
    end

    test "Adding more items to basket than are in stock", context do
      product = insert(:product, %{stock_qty: 2})
      basket = insert(:basket)

      mutation = add_to_basket_mutation(basket.id, product.id, 3)

      res = make_mutation(context.conn, mutation)

      assert List.first(res["errors"])["message"] ==
               "There is not enough stock to add this to the basket"
    end

    test "Removing a product from the basket that is in the basket", context do
      basket_item = insert(:basket_item) |> Repo.preload(:basket)

      mutation = remove_item_from_basket(basket_item.basket_id, basket_item.id)

      make_mutation(context.conn, mutation)

      assert basket_item.basket |> get_basket_items |> Enum.count() == 0
    end
  end

  defp add_to_basket_mutation(basket_id, product_id, quantity \\ 1) do
    """
    mutation {
      addProductToBasket(basketId:"#{basket_id}", productId:#{product_id}, quantity:#{quantity}) {
        id
        items {
          id
        }
      }
    }
    """
  end

  defp remove_item_from_basket(basket_id, item_id) do
    """
    mutation {
      removeProductFromBasket(basketId:"#{basket_id}", itemId:#{item_id}) {
        id
      }
    }
    """
  end

  defp get_basket_items(basket) do
    basket |> Repo.preload(:basket_items) |> Map.get(:basket_items)
  end

  defp make_mutation(conn, mutation) do
    conn
    |> post("/graphql", mutation |> AbsintheHelpers.mutation_skeleton())
    |> json_response(200)
  end
end
