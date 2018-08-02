defmodule Bazaar.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add(:user_id, references(:users))

      add(:name, :string)
      add(:phone, :string)
      add(:line_1, :string)
      add(:line_2, :string)
      add(:line_3, :string)
      add(:city, :string, null: false)
      add(:postcode, :string, null: false)
      add(:country, :char, null: false, size: 2)

      timestamps()
    end
  end
end
