defmodule Bazaar.Schema.ProductTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Resolvers.ProductResolver
  alias Bazaar.GraphQl.Utils

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

    field(
      :created_at,
      non_null(:naive_datetime),
      resolve: &Utils.resolve_created_date/3
    )

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

  object :create_product_response do
    field(:entity, :product)
    field(:validation, list_of(non_null(:validation)))
  end

  object :update_product_response do
    field(:entity, :product)
    field(:validation, list_of(non_null(:validation)))
  end

  object :paged_products do
    field(:products, non_null(list_of(non_null(:product))))
    field(:pagination, non_null(:pagination))
  end

  object :product_queries do
    @desc "Get a paginated list of products"
    field(:product_list, :paged_products) do
      arg(:page, :integer)
      arg(:page_size, :integer)
      resolve(&ProductResolver.all/3)
    end

    @desc "Get a single product by id or slug"
    field(:product, :product) do
      arg(:id, :id)
      arg(:slug, :string)
      resolve(&ProductResolver.get/3)
    end
  end

  object :product_mutations do
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

      resolve(Utils.handle_errors(&ProductResolver.create/3))
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

      resolve(Utils.handle_errors(&ProductResolver.update/3))
    end
  end
end
