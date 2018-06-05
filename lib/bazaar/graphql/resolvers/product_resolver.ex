defmodule Bazaar.GraphQl.Resolvers.ProductResolver do
  alias Bazaar.Product
  alias Bazaar.Repo

  def all(_root, _args, _info) do
    products = Repo.all(Product)
    {:ok, products}
  end

  def create(_root, args, _info) do
    Product.changeset(%Product{}, args)
    |> Repo.insert()
  end
end
