defmodule Bazaar.Repo.Migrations.CreateRoles do
  use Ecto.Migration

  def change do
    create table(:roles) do
      add(:slug, :string, null: false)
      add(:name, :string)
      add(:description, :string)

      timestamps()
    end

    create(index(:roles, [:slug], unique: true))
  end
end
