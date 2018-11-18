defmodule Bazaar.Product do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Bazaar.Repo
  alias Bazaar.Product

  schema "products" do
    field(:name, :string)
    field(:description, :string)
    field(:slug, :string)
    field(:status, :string)
    field(:sku, :string)
    field(:price, :integer)
    field(:sale_price, :integer)
    field(:stock_qty, :integer)
    field(:location, :string)
    field(:featured, :boolean)
    field(:listed, :boolean)
    field(:deleted_at, :naive_datetime)

    belongs_to(:user, Bazaar.User)

    has_many(:product_images, Bazaar.ProductImage)

    many_to_many(
      :categories,
      Bazaar.Category,
      join_through: "categories_products",
      on_delete: :delete_all
    )

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [
      :name,
      :description,
      :slug,
      :status,
      :sku,
      :price,
      :sale_price,
      :stock_qty,
      :location,
      :featured,
      :listed
    ])
    |> validate_required([:name, :description, :slug, :sku, :price])
    |> unique_constraint(:name)
    |> unique_constraint(:slug)
    |> unique_constraint(:sku)
  end

  def payable_price(%Bazaar.Product{sale_price: nil, price: price}) do
    price
  end

  def payable_price(%Bazaar.Product{sale_price: sale_price}) do
    sale_price
  end

  def list(args) do
    page =
      Product
      |> order_by(desc: :inserted_at)
      |> preload(:categories)
      |> preload(:product_images)
      |> Repo.paginate(page: Map.get(args, :page, 1), page_size: Map.get(args, :page_size, 12))

    %{
      products: page.entries,
      pagination: %{
        page_number: page.page_number,
        page_size: page.page_size,
        total_pages: page.total_pages,
        total_entries: page.total_entries
      }
    }
  end
end
