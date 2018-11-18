defmodule Bazaar.Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "roles" do
    field(:description, :string)
    field(:name, :string)
    field(:slug, :string)

    has_many(:users, Bazaar.User)
    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:name, :slug, :description])
    |> unique_constraint(:slug)
    |> validate_required([:name, :slug, :description])
  end
end
