defmodule Bazaar.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add(:name, :string, null: false)
      add(:slug, :string, null: false)
      add(:description, :text, null: true)
      add(:status, :string, default: "published")
      add(:price, :integer, default: 0)
      add(:sale_price, :integer, null: true)
      add(:stock_qty, :integer, null: true)
      add(:sku, :string, null: true)
      add(:user_id, :integer)
      add(:location, :string, null: true)
      add(:featured, :boolean, null: false, default: false)
      add(:listed, :boolean, null: false, default: true)
      add(:published_at, :timestamp, null: true)
      add(:deleted_at, :timestamp, null: true)
      timestamps()
    end

    create(index(:products, [:sku], unique: true))
  end
end
