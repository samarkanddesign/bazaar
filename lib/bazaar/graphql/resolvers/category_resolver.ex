defmodule Bazaar.GraphQl.Resolvers.CategoryResolver do
  alias Bazaar.Category
  alias Bazaar.Repo

  def all(_root, _args, _info) do
    categories = Repo.all(Category) |> Repo.preload(:products)
    {:ok, categories}
  end

  def get(_root, %{id: id}, _info) do
    {:ok, Repo.get(Category, id) |> Repo.preload(:products)}
  end

  def get(_root, %{slug: slug}, _info) do
    {:ok, Repo.get_by(Category, slug: slug) |> Repo.preload(:products)}
  end

  def get(_root, _args, _info) do
    {:error, "An 'id' or 'slug' argument must be provided"}
  end

  def create(_root, args, _info) do
    Category.changeset(%Category{}, args)
    |> Repo.insert()
  end
end
