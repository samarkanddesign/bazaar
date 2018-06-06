defmodule Bazaar.GraphQl.Resolvers.CategoryResolver do
  alias Bazaar.Category
  alias Bazaar.Repo

  def all(_root, _args, _info) do
    categories = Repo.all(Category) |> Repo.preload(:products)
    {:ok, categories}
  end

  def create(_root, args, _info) do
    Category.changeset(%Category{}, args)
    |> Repo.insert()
  end
end
