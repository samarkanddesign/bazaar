defmodule Bazaar.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field(:name, :string)
    field(:description, :string)
    field(:slug, :string)
    field(:status, :string)
    field(:sku, :string)
    field(:price, :integer)
    field(:sale_price, :integer)
    field(:stock_qty, :integer)
    field(:location, :string)
    field(:featured, :boolean)
    field(:listed, :boolean)
    field(:deleted_at, :naive_datetime)

    belongs_to(:user, Bazaar.User)

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :slug,
      :status,
      :sku,
      :price,
      :sale_price,
      :stock_qty,
      :location,
      :featured,
      :listed
    ])
    |> validate_required([:name, :description, :slug, :sku, :price, :featured])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> unique_constraint(:sku)
  end
end
