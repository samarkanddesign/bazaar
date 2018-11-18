defmodule Bazaar.Repo.Migrations.CreateProductImage do
  use Ecto.Migration

  def change do
    create table(:product_images) do
      add(:image, :string)
      add(:product_id, references(:products, on_delete: :delete_all), null: false)

      timestamps()
    end
  end
end
