defmodule Bazaar.Schema.OrderTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Utils
  alias Bazaar.GraphQl.Resolvers.OrderResolver

  object :order_item do
    field(:description, non_null(:string))
    field(:price_paid, non_null(:integer))
    field(:order, non_null(:order), resolve: assoc(:order))
    field(:product, :product, resolve: assoc(:product))
  end

  object :order do
    field(:id, non_null(:id))
    field(:status, non_null(:string))
    field(:note, :string)
    field(:shipping_address, non_null(:address), resolve: assoc(:shipping_address))
    field(:billing_address, non_null(:address), resolve: assoc(:billing_address))
    field(:items, non_null(list_of(:order_item)), resolve: assoc(:order_items))
    field(:user, non_null(:user), resolve: assoc(:user))
    field(:total, non_null(:integer), resolve: &calc_order_total/3)

    field(
      :created_at,
      non_null(:naive_datetime),
      resolve: &Utils.resolve_created_date/3
    )
  end

  object :order_mutations do
    field(:place_order, type: :place_order_response) do
      arg(:basket_id, non_null(:uuid))
      arg(:shipping_address_id, non_null(:integer))
      arg(:billing_address_id, non_null(:integer))

      resolve(&OrderResolver.place_order/3)
    end
  end

  defp calc_order_total(_root, _args, %{source: %Bazaar.Order{order_items: items}}) do
    {:ok, Enum.reduce(items, 0, fn %{price_paid: amount}, total -> total + amount end)}
  end
end
