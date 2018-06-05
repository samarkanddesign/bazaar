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

  object :create_product_response do
    field(:product, :product)
    field(:errors, list_of(:error))
  end

  object :error do
    field(:key, non_null(:string))
    field(:reason, non_null(:string))
  end

  query do
    field(:products, non_null(list_of(non_null(:product)))) do
      resolve(&ProductResolver.all/3)
    end
  end

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
    # {:error, [email: {"has already been taken", []}]}
    errors =
      changeset.errors
      |> Enum.map(fn {key, {value, _context}} -> %{key: key, reason: value} end)

    IO.inspect(errors)

    {:ok, %{errors: errors}}
  end
end
