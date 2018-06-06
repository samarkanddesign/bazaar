defmodule Bazaar.GraphQl.Resolvers.ProductResolver do
  alias Bazaar.Product
  alias Bazaar.Repo

  def all(_root, _args, _info) do
    products = Repo.all(Product) |> Repo.preload(:categories)
    {:ok, products}
  end

  def get(_root, %{id: id}, _info) do
    {:ok, Repo.get(Product, id) |> Repo.preload(:categories)}
  end

  def get(_root, %{slug: slug}, _info) do
    {:ok, Repo.get_by(Product, slug: slug) |> Repo.preload(:categories)}
  end

  def get(_root, _args, _info) do
    {:error, "An 'id' or 'slug' argument must be provided"}
  end

  def create(_root, args, _info) do
    Product.changeset(%Product{}, args)
    |> Repo.insert()
  end
end
