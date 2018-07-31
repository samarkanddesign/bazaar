defmodule BazaarWeb.ProductResolverTest do
  use BazaarWeb.ConnCase

  alias Bazaar.Repo
  alias Bazaar.Product
  import Bazaar.Factory
  alias Bazaar.AbsintheHelpers

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
        |> AbsintheHelpers.query_skeleton("Product")

      res =
        context.conn
        |> post("/graphql", query)
        |> json_response(200)

      assert res["data"]["product"]["name"] == product.name
    end

    test "creating a product", context do
      product = build(:product)
      user = build(:user) |> make_admin() |> insert

      {:ok, jwt, _claims} = Bazaar.Auth.Guardian.encode_and_sign(user)

      mutation = create_product_mutation(product)

      res =
        context.conn
        |> Plug.Conn.put_req_header("authorization", "Bearer #{jwt}")
        |> post("/graphql", mutation)
        |> json_response(200)

      assert res["data"]["createProduct"]["entity"]["slug"] == product.slug
      assert Repo.get_by(Bazaar.Product, %{slug: product.slug}) != nil
    end

    test "creating a product when unauthenticated", context do
      product = build(:product)

      mutation = create_product_mutation(product)

      res =
        context.conn
        |> post("/graphql", mutation)
        |> json_response(200)

      assert AbsintheHelpers.first_error(res) == "Unauthorized"
      assert Repo.get_by(Bazaar.Product, %{slug: product.slug}) == nil
    end

    test "updating a product", context do
      product = insert(:product)

      user = build(:user) |> make_admin() |> insert
      {:ok, jwt, _claims} = Bazaar.Auth.Guardian.encode_and_sign(user)

      mutation =
        """
        mutation {
          updateProduct(id:#{product.id}, price:222) {
            entity {
              price
            }
          }
        }
        """
        |> AbsintheHelpers.mutation_skeleton()

      res =
        context.conn
        |> Plug.Conn.put_req_header("authorization", "Bearer #{jwt}")
        |> post("/graphql", mutation)
        |> json_response(200)

      assert res["data"]["updateProduct"]["entity"]["price"] == 222
      assert Repo.get(Product, product.id) |> Map.get(:price) == 222
    end

    defp create_product_mutation(product) do
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
      |> AbsintheHelpers.mutation_skeleton()
    end
  end
end
