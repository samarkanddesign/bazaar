defmodule Bazaar.Repo.Migrations.CreateBasketItems do
  use Ecto.Migration

  def up do
    create table(:baskets, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      timestamps()
    end

    create table(:basket_items) do
      add(:basket_id, references(:baskets, type: :uuid), on_delete: :delete_all)
      add(:product_id, references(:products), on_delete: :delete_all)
      add(:quantity, :integer, null: false)
      timestamps()
    end

    create(
      unique_index(
        :basket_items,
        [:basket_id, :product_id],
        name: :basket_items_basket_id_product_id_unique
      )
    )
  end

  def down do
    drop(table(:basket_items))
    drop(table(:baskets))
  end
end
