defmodule Bazaar.GraphQl.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Resolvers.ProductResolver
  alias Bazaar.GraphQl.Resolvers.CategoryResolver
  alias Bazaar.GraphQl.Resolvers.BasketResolver

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

    field(:thumbnail, :product_image, resolve: &ProductResolver.thumbnail/3)

    field(
      :images,
      non_null(list_of(non_null(:product_image))),
      resolve: &ProductResolver.product_images/3
    )

    field(:categories, non_null(list_of(non_null(:category))), resolve: assoc(:categories))
  end

  object :product_image do
    field(:id, non_null(:id))
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

  object :update_product_response do
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
    field(:products, non_null(list_of(non_null(:product))))
    field(:pagination, non_null(:pagination))
  end

  object :basket do
    field(:basket_id, non_null(:string))
    field(:items, non_null(list_of(:basket_item)), resolve: assoc(:basket_items))
    field(:created_at, non_null(:naive_datetime), resolve: &resolve_created_date/3)
    field(:updated_at, non_null(:naive_datetime))
  end

  object :basket_item do
    field(:id, non_null(:id))
    field(:product, non_null(:product), resolve: assoc(:product))
    field(:quantity, non_null(:integer))
  end

  query do
    @desc "Get a paginated list of products"
    field(:product_list, :paged_products) do
      arg(:page, :integer)
      resolve(&ProductResolver.all/3)
    end

    @desc "Get a single product by id or slug"
    field(:product, :product) do
      arg(:id, :id)
      arg(:slug, :string)
      resolve(&ProductResolver.get/3)
    end

    field(:cart_products, non_null(list_of(:product))) do
      arg(:ids, non_null(list_of(:id)))
      resolve(&ProductResolver.cart_products/3)
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

    @desc "Update an existing product"
    field :update_product, type: :update_product_response do
      arg(:id, non_null(:id))
      arg(:name, :string)
      arg(:description, :string)
      arg(:slug, :string)
      arg(:sku, :string)
      arg(:price, :integer)
      arg(:sale_price, :integer)
      arg(:stock_qty, :integer)
      arg(:featured, :boolean)
      arg(:listed, :boolean)

      resolve(handle_errors(&ProductResolver.update/3))
    end

    @desc "Add a product to the basket using an existing or new basket identifier"
    field :add_product_to_basket, type: :basket do
      arg(:basket_id, non_null(:string))
      arg(:product_id, non_null(:integer))
      arg(:quantity, non_null(:integer))

      resolve(&BasketResolver.add_item_to_basket/3)
    end

    field :remove_product_from_basket, type: :basket do
      arg(:basket_id, non_null(:string))
      arg(:item_id, non_null(:integer))

      resolve(&BasketResolver.remove_item_from_basket/3)
    end
  end

  def resolve_created_date(_root, _args, %{source: %{inserted_at: inserted_at}}) do
    {:ok, inserted_at}
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
