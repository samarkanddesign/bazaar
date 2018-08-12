defmodule Bazaar.Schema.AddressTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Resolvers.AddressResolver

  object :address do
    field(:id, non_null(:id))
    field(:name, :string)
    field(:phone, :string)
    field(:line1, :string)
    field(:line2, :string)
    field(:line3, :string)
    field(:city, non_null(:string))
    field(:postcode, non_null(:string))
    field(:country, non_null(:string))
  end

  object :address_queries do
    field(:user_addresses, type: non_null(list_of(non_null(:address)))) do
      resolve(&AddressResolver.user_addresses/3)
    end
  end
end
