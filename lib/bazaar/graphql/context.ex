defmodule Bazaar.Context do
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    case Guardian.Plug.current_resource(conn) do
      nil -> Absinthe.Plug.put_options(conn, context: %{current_user: nil})
      user -> Absinthe.Plug.put_options(conn, context: %{current_user: user})
    end
  end
end
