defmodule Bazaar.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table("orders") do
      add(:user_id, references(:users))
      add(:shipping_address_id, references(:addresses))
      add(:billing_address_id, references(:addresses))
      add(:status, :string)
      add(:note, :string)
      add(:payment_id, :string)
      add(:invoice_id, :string)

      timestamps()
    end
  end
end
