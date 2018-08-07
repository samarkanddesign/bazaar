defmodule Bazaar.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field(:note, :string)
    field(:status, :string)

    has_many(:order_items, Bazaar.OrderItem)
    belongs_to(:shipping_address, Bazaar.Address)
    belongs_to(:billing_address, Bazaar.Address)
    belongs_to(:user, Bazaar.User)

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :shipping_address_id,
      :billing_address_id
    ])
    |> validate_required([
      :shipping_address_id,
      :billing_address_id
    ])
  end
end
