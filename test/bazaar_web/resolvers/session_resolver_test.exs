defmodule BazaarWeb.SessionResolverTest do
  use BazaarWeb.ConnCase
  alias Bazaar.AbsintheHelpers
  import Bazaar.Factory

  describe "Session Resolver" do
    test "logging in with correct credentials", context do
      user = insert(:user, %{password_hash: Comeonin.Bcrypt.hashpwsalt("secret")})

      res =
        login_mutation(user.email, "secret")
        |> make_mutation(context.conn)

      # jwts start with ey
      assert String.slice(res["data"]["login"]["jwt"], 0..1) == "ey"
    end

    test "logging in with incorrect password", context do
      user = insert(:user)

      res =
        login_mutation(user.email, "thisiswrong")
        |> make_mutation(context.conn)

      assert AbsintheHelpers.first_error(res) == "Invalid credentials"
    end
  end

  defp login_mutation(email, password) do
    """
    mutation {
      login(email:"#{email}", password:"#{password}") {
        user {
          name
        }
        jwt
      }
    }
    """
  end

  def make_mutation(mutation, conn) do
    conn
    |> post("/graphql", mutation |> AbsintheHelpers.mutation_skeleton())
    |> json_response(200)
  end
end
