defmodule BazaarWeb.ProductResolverTest do
  use BazaarWeb.ConnCase

  alias Bazaar.Repo
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

    test "creating a product", context do
      product = build(:product)
      user = insert(:user)
      {:ok, jwt, _claims} = Bazaar.Auth.Guardian.encode_and_sign(user)

      mutation =
        """
        mutation {
          createProduct(
            name:"#{product.name}",
            slug:"#{product.slug}",
            price:#{product.price},
            sku:"#{product.sku}",
            description:"#{product.description}"
          ) {
            validation {
              key
              reason
            }
            entity {
              id
              name
              slug
            }
          }
        }
        """
        |> Bazaar.AbsintheHelpers.mutation_skeleton()

      res =
        context.conn
        |> Plug.Conn.put_req_header("authorization", "Bearer #{jwt}")
        |> post("/graphql", mutation)
        |> json_response(200)

      assert res["data"]["createProduct"]["entity"]["slug"] == product.slug
      assert Repo.get_by(Bazaar.Product, %{slug: product.slug}) != nil
    end
  end
end
