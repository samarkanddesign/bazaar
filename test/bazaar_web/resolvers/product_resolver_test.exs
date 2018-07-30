defmodule BazaarWeb.ProductResolverTest do
  use BazaarWeb.ConnCase

  import Bazaar.Factory

  describe "Product Resolver" do
    test "getting a product", context do
      product = insert(:product)

      query =
        """
        {
          product(id:#{product.id}) {
            name
            slug
          }
        }
        """
        |> Bazaar.AbsintheHelpers.query_skeleton("Product")

      res =
        context.conn
        |> post("/graphql", query)
        |> json_response(200)

      assert res["data"]["product"]["name"] == product.name
    end
  end
end
