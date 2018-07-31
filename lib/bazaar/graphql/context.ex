defmodule Bazaar.Context do
  @behaviour Plug
  alias Bazaar.Repo

  def init(opts), do: opts

  def call(conn, _) do
    case Guardian.Plug.current_resource(conn) do
      nil ->
        Absinthe.Plug.put_options(conn, context: %{})

      user ->
        Absinthe.Plug.put_options(
          conn,
          context: %{current_user: user, admin: check_if_admin(user)}
        )
    end
  end

  defp check_if_admin(%Bazaar.User{role_id: role_id}) do
    case role_id do
      nil ->
        false

      id ->
        case Repo.get_by(Bazaar.Role, %{id: id, slug: "admin"}) do
          nil -> false
          _ -> true
        end
    end
  end
end
