defmodule Bazaar.GraphQl.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Resolvers.ProductResolver

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
  end

  query do
    field(:products, non_null(list_of(non_null(:product)))) do
      resolve(&ProductResolver.all/3)
    end
  end

  def resolve_created_date(_root, _args, %{source: %{inserted_at: inserted_at}}) do
    {:ok, inserted_at}
  end
end
