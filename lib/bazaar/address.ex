defmodule Bazaar.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field(:name, :string)
    field(:phone, :string)
    field(:line_1, :string)
    field(:line_2, :string)
    field(:line_3, :string)
    field(:city, :string)
    field(:postcode, :string)
    field(:country, :string)

    belongs_to(:user, Bazaar.User)

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :phone, :line_1, :line_2, :line_3, :city, :country, :postcode])
    |> validate_required([:name, :line_1, :city, :country, :postcode])
  end
end
