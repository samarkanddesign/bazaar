defmodule Bazaar.Repo.Migrations.CreateOrderItems do
  use Ecto.Migration

  def change do
    create table("order_items") do
      add(:order_id, references(:orders))
      add(:product_id, references(:products))

      add(:description, :string, null: false)
      add(:price_paid, :integer, null: false)
      add(:quantity, :integer, null: false)
    end
  end
end
