defmodule Bazaar.OrderItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "order_items" do
    field(:description, :string)
    field(:price_paid, :integer)
    field(:quantity, :integer)

    belongs_to(:order, Bazaar.Order)
    belongs_to(:product, Bazaar.Product)
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [])
  end
end
