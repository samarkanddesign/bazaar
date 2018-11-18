defmodule Bazaar.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:name, :string)
      add(:email, :string, null: false)
      add(:password_hash, :string)

      add(:role_id, references(:roles, on_delete: :delete_all))
      add(:billing_token, :string)
      timestamps()
    end

    create(index(:users, [:email], unique: true))
  end
end
