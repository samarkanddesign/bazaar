defmodule Bazaar.GraphQl.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Resolvers.CategoryResolver
  alias Bazaar.GraphQl.Resolvers.SessionResolver

  import_types(Absinthe.Type.Custom)
  import_types(Bazaar.Schema.Types.Custom.UUID)
  import_types(Bazaar.Schema.ProductTypes)
  import_types(Bazaar.Schema.BasketTypes)
  import_types(Bazaar.Schema.OrderTypes)
  import_types(Bazaar.Schema.AddressTypes)

  object :user do
    field(:id, non_null(:id))
    field(:email, non_null(:string))
    field(:name, non_null(:string))
  end

  object :category do
    field(:id, non_null(:id))

    field(:term, non_null(:string))
    field(:slug, non_null(:string))
    field(:order, non_null(:integer))

    field(:products, non_null(list_of(non_null(:product))), resolve: assoc(:products))
  end

  @desc "A validation error"
  object :validation do
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

  object :session do
    field(:jwt, non_null(:string))
    field(:user, non_null(:user))
  end

  object :register_response do
    field(:entity, :session)
    field(:validation, non_null(list_of(non_null(:validation))))
  end

  query do
    import_fields(:basket_queries)
    import_fields(:product_queries)
    import_fields(:address_queries)

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
    @desc "Obtain a JWT"
    field :login, type: :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&SessionResolver.login/3)
    end

    @desc "Register a new user and login"
    field :register, type: :register_response do
      arg(:name, non_null(:string))
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(Bazaar.GraphQl.Utils.handle_errors(&SessionResolver.register/3))
    end

    import_fields(:product_mutations)
    import_fields(:basket_mutations)
    import_fields(:order_mutations)
    import_fields(:address_mutations)
  end
end
