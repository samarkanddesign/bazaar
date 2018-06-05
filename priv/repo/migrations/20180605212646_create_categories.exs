defmodule Bazaar.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add(:term, :string, null: false)
      add(:slug, :string, null: false)
      add(:order, :integer, default: 0)

      timestamps()
    end
  end
end
