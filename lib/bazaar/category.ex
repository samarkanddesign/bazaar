defmodule Bazaar.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field(:order, :integer)
    field(:slug, :string)
    field(:term, :string)

    many_to_many(:products, Bazaar.Product, join_through: "categories_products")

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:term, :slug, :order])
    |> validate_required([:term, :slug])
  end
end
