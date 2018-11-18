defmodule Bazaar.Repo.Migrations.CreateCategoriesProducts do
  use Ecto.Migration

  def up do
    create table(:categories_products) do
      add(:category_id, references(:categories, on_delete: :delete_all), null: false)
      add(:product_id, references(:products, on_delete: :delete_all), null: false)
    end

    create(
      unique_index(
        :categories_products,
        [:category_id, :product_id],
        name: :categories_products_category_id_product_id_unique
      )
    )
  end

  def down do
    drop(table(:categories_products))
  end
end
