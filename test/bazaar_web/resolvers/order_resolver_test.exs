defmodule BazaarWeb.OrderResolverTest do
  use BazaarWeb.ConnCase

  import Bazaar.Factory

  alias Bazaar.Repo
  alias Bazaar.AbsintheHelpers

  describe "Order resolver" do
    test "placing a new order", context do
      %{id: address_id, user: user} = insert(:address) |> Repo.preload(:user)
      product = insert(:product, %{sale_price: 3})

      %{basket: basket} = insert(:basket_item, %{product: product}) |> Repo.preload(:basket)
      {:ok, jwt, _claims} = Bazaar.Auth.Guardian.encode_and_sign(user)

      mutation = """
        mutation {
          placeOrder(basketId: "#{basket.id}", billingAddressId:#{address_id}, shippingAddressId:#{
        address_id
      }) {
            status
            order {
              id
              items {
                description
              }
              shipping_address {
                line_1
              }
              user {
                email
              }
              total
            }
          }
        }
      """

      res =
        make_mutation(
          context.conn |> Plug.Conn.put_req_header("authorization", "Bearer #{jwt}"),
          mutation
        )

      assert res["data"]["placeOrder"]["order"]["total"] == 3
      assert res["data"]["placeOrder"]["status"] == "ok"
    end
  end

  defp make_mutation(conn, mutation) do
    conn
    |> post("/graphql", mutation |> AbsintheHelpers.mutation_skeleton())
    |> json_response(200)
  end
end
