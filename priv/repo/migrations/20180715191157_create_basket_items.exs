defmodule Bazaar.Repo.Migrations.CreateBasketItems do
  use Ecto.Migration

  def up do
    create table(:baskets) do
      add(:basket_id, :string, null: false)
      timestamps()
    end

    create table(:basket_items) do
      add(:basket_id, references(:baskets))
      add(:product_id, references(:products))
      add(:quantity, :integer, null: false)
      timestamps()
    end

    create(index(:baskets, [:basket_id], unique: true))
    create(unique_index(:basket_items, [:basket_id, :product_id]))
  end

  def down do
    drop(table(:basket_items))
    drop(table(:baskets))
  end
end
