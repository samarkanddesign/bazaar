defmodule Bazaar.GraphQl.Resolvers.AddressResolver do
  alias Bazaar.Repo

  def user_addresses(_root, _args, %{context: %{current_user: user}}) do
    {:ok,
     user
     |> Repo.preload(:addresses)
     |> Map.get(:addresses, [])}
  end

  def user_addresses(_root, _args, _info) do
    {:error, "No user 🙁"}
  end
end
