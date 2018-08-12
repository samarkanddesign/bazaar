defmodule Bazaar.GraphQl.Resolvers.AddressResolver do
  alias Bazaar.Repo
  alias Bazaar.Address

  def user_addresses(_root, _args, %{context: %{current_user: user}}) do
    {:ok,
     user
     |> Repo.preload(:addresses)
     |> Map.get(:addresses, [])}
  end

  def user_addresses(_root, _args, _info) do
    {:error, "Unauthorized 🙁"}
  end

  def create_address(_root, args, %{context: %{current_user: user}}) do
    Address.changeset(%Address{user_id: user.id}, args)
    |> Repo.insert()
  end

  def create_address(_root, _args, _info) do
    {:error, "Unauthorized 🙁"}
  end
end
