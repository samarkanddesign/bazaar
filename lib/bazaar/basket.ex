defmodule Bazaar.Basket do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "baskets" do
    has_many(:basket_items, Bazaar.BasketItem)

    timestamps()
  end

  @doc false
  def changeset(basket, attrs) do
    basket
    |> cast(attrs, [])
  end
end
