defmodule Bazaar.BasketItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "basket_items" do
    field(:price, :integer)
    field(:quantity, :integer)

    belongs_to(:basket, Bazaar.Basket)
    belongs_to(:product, Bazaar.Product)

    timestamps()
  end

  @doc false
  def changeset(basket, attrs) do
    basket
    |> cast(attrs, [:basket_id, :quantity])
  end
end
