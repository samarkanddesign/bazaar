defmodule Bazaar.Repo.Migrations.CreateBasketItems do
  use Ecto.Migration

  def change do
    create table(:baskets) do
      add(:basket_id, :string, null: false)
      timestamps()
    end

    create table(:basket_items) do
      add(:basket_id, references(:baskets))
      add(:product_id, references(:products))
      add(:price, :integer, null: false)
      add(:quantity, :integer)
      timestamps()
    end
  end
end
