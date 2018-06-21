defmodule Bazaar.GraphQl.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Resolvers.ProductResolver
  alias Bazaar.GraphQl.Resolvers.CategoryResolver

  import_types(Absinthe.Type.Custom)

  object :product do
    field(:id, non_null(:id))

    field(:name, non_null(:string))
    field(:description, non_null(:string))
    field(:slug, non_null(:string))
    field(:sku, non_null(:string))
    field(:price, non_null(:integer))
    field(:sale_price, :integer)
    field(:stock_qty, :integer)
    field(:featured, non_null(:boolean))
    field(:listed, non_null(:boolean))
    field(:created_at, non_null(:naive_datetime), resolve: &resolve_created_date/3)

    field(
      :images,
      non_null(list_of(non_null(:product_image))),
      resolve: &resolve_product_images/3
    )

    field(:categories, non_null(list_of(non_null(:category))), resolve: assoc(:categories))
  end

  object :product_image do
    field(:url, non_null(:string))
  end

  object :category do
    field(:id, non_null(:id))

    field(:term, non_null(:string))
    field(:slug, non_null(:string))
    field(:order, non_null(:integer))

    field(:products, non_null(list_of(non_null(:product))), resolve: assoc(:products))
  end

  object :create_product_response do
    field(:product, :product)
    field(:errors, list_of(:error))
  end

  @desc "A validation error"
  object :error do
    field(:key, non_null(:string))
    field(:reason, non_null(:string))
  end

  @desc "Pagination information for a paged query"
  object :pagination do
    field(:page_number, non_null(:integer))
    field(:page_size, non_null(:integer))
    field(:total_pages, non_null(:integer))
    field(:total_entries, non_null(:integer))
  end

  object :paged_products do
    field(:items, non_null(list_of(non_null(:product))))
    field(:pagination, non_null(:pagination))
  end

  query do
    @desc "Get a paginated list of products"
    field(:products, :paged_products) do
      arg(:page, :integer)
      resolve(&ProductResolver.all/3)
    end

    @desc "Get a single product by id or slug"
    field(:product, :product) do
      arg(:id, :id)
      arg(:slug, :string)
      resolve(&ProductResolver.get/3)
    end

    @desc "Get all categories"
    field(:categories, non_null(list_of(non_null(:category)))) do
      resolve(&CategoryResolver.all/3)
    end

    @desc "Get a single category by id or slug"
    field(:category, :category) do
      arg(:id, :id)
      arg(:slug, :string)
      resolve(&CategoryResolver.get/3)
    end
  end

  @desc "Create a new product"
  mutation do
    field :create_product, type: :create_product_response do
      arg(:name, non_null(:string))
      arg(:description, non_null(:string))
      arg(:slug, non_null(:string))
      arg(:sku, non_null(:string))
      arg(:price, non_null(:integer))
      arg(:sale_price, :integer)
      arg(:stock_qty, :integer)
      arg(:featured, :boolean)
      arg(:listed, :boolean)

      resolve(handle_errors(&ProductResolver.create/3))
    end
  end

  def resolve_created_date(_root, _args, %{source: %{inserted_at: inserted_at}}) do
    {:ok, inserted_at}
  end

  def resolve_product_images(_root, _args, %{source: %{product_images: product_images}}) do
    {:ok,
     Enum.map(product_images, fn image ->
       %{url: Bazaar.Uploaders.ProductImage.url(image.image, image)}
     end)}
  end

  def handle_errors(fun) do
    fn source, args, info ->
      case Absinthe.Resolution.call(fun, source, args, info) do
        {:error, %Ecto.Changeset{} = changeset} -> format_changeset(changeset)
        {:ok, product} -> {:ok, %{product: product}}
        val -> val
      end
    end
  end

  def format_changeset(changeset) do
    errors =
      changeset.errors
      |> Enum.map(fn {key, {value, _context}} -> %{key: key, reason: value} end)

    {:ok, %{errors: errors}}
  end
end
