defmodule Bazaar.GraphQl.Resolvers.ProductResolver do
  alias Bazaar.Product
  alias Bazaar.Repo

  def all(_root, _args, _info) do
    products = Repo.all(Product)
    {:ok, products}
  end
end
