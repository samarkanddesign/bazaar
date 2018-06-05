defmodule Bazaar.Repo.Migrations.CreateCategoriesProducts do
  use Ecto.Migration

  def up do
    create table(:categories_products) do
      add(:category_id, references(:categories))
      add(:product_id, references(:products))
    end

    create(unique_index(:categories_products, [:category_id, :product_id]))
  end

  def down do
    drop(table(:categories_products))
  end
end
