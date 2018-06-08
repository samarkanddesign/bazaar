defmodule Bazaar.GraphQl.Resolvers.ProductResolver do
  import Ecto.Query
  alias Bazaar.Product
  alias Bazaar.Repo

  def all(_root, args, _info) do
    page =
      Product
      |> order_by(desc: :created_at)
      |> preload(:categories)
      |> Repo.paginate(page: Map.get(args, :page, 1))

    {:ok, page.entries}
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
