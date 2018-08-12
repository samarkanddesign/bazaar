defmodule Bazaar.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users))

      add(:name, :string)
      add(:phone, :string)
      add(:line1, :string)
      add(:line2, :string)
      add(:line3, :string)
      add(:city, :string, null: false)
      add(:postcode, :string, null: false)
      add(:country, :char, null: false, size: 2)

      timestamps()
    end
  end
end
