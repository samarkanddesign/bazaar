defmodule Bazaar.Schema.BasketTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Resolvers.BasketResolver
  alias Bazaar.GraphQl.Utils

  object :update_basket_response do
    field(:entity, :basket)
    field(:validation, list_of(non_null(:validation)))
  end

  object :basket do
    field(:id, non_null(:uuid))
    field(:items, non_null(list_of(non_null(:basket_item))), resolve: assoc(:basket_items))

    field(
      :created_at,
      non_null(:naive_datetime),
      resolve: &Utils.resolve_created_date/3
    )

    field(:updated_at, non_null(:naive_datetime))
  end

  object :basket_item do
    field(:id, non_null(:id))
    field(:product, non_null(:product), resolve: assoc(:product))
    field(:quantity, non_null(:integer))
  end

  object :basket_queries do
    @desc "Get a basket by its identifier"
    field(:basket, :basket) do
      arg(:basket_id, :uuid)

      resolve(&BasketResolver.get_basket/3)
    end
  end

  object :basket_mutations do
    @desc "Create a new basket with a unique ID"
    field :create_basket, type: non_null(:basket) do
      resolve(&BasketResolver.create_basket/3)
    end

    @desc "Add a product to the basket using an existing basket identifier"
    field :add_product_to_basket, type: :update_basket_response do
      arg(:basket_id, non_null(:uuid))
      arg(:product_id, non_null(:integer))
      arg(:quantity, non_null(:integer))

      resolve(Utils.handle_errors(&BasketResolver.add_item_to_basket/3))
    end

    @desc "Remove a product from a basket"
    field :remove_product_from_basket, type: :basket do
      arg(:basket_id, non_null(:uuid))
      arg(:item_id, non_null(:integer))

      resolve(&BasketResolver.remove_item_from_basket/3)
    end
  end
end
