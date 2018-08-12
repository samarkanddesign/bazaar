defmodule Bazaar.Address do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "addresses" do
    field(:name, :string)
    field(:phone, :string)
    field(:line1, :string)
    field(:line2, :string)
    field(:line3, :string)
    field(:city, :string)
    field(:postcode, :string)
    field(:country, :string)

    belongs_to(:user, Bazaar.User)

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :phone, :line1, :line2, :line3, :city, :country, :postcode])
    |> validate_required([:name, :line1, :city, :country, :postcode])
  end
end
