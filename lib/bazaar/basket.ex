defmodule Bazaar.Basket do
  use Ecto.Schema
  import Ecto.Changeset

  schema "baskets" do
    field(:basket_id, :string)

    has_many(:basket_items, Bazaar.BasketItem)

    timestamps()
  end

  @doc false
  def changeset(basket, attrs) do
    basket
    |> cast(attrs, [:basket_id])
  end
end
