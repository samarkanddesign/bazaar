defmodule Bazaar.BasketItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "basket_items" do
    field(:quantity, :integer)

    belongs_to(:basket, Bazaar.Basket, type: :binary_id)
    belongs_to(:product, Bazaar.Product)

    timestamps()
  end

  @doc false
  def changeset(basket, attrs) do
    basket
    |> unique_constraint(:product, name: :basket_items_basket_id_product_id_unique)
    |> cast(attrs, [:basket_id, :quantity, :product_id])
  end
end
