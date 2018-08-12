defmodule Bazaar.Schema.AddressTypes do
  use Absinthe.Schema.Notation
  use Absinthe.Ecto, repo: Bazaar.Repo

  alias Bazaar.GraphQl.Resolvers.AddressResolver
  alias Bazaar.GraphQl.Utils

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

  object :create_address_response do
    field(:entity, :address)
    field(:validation, list_of(:validation))
  end

  object :address_mutations do
    field(:create_address, type: non_null(:create_address_response)) do
      arg(:name, :string)
      arg(:phone, :string)
      arg(:line1, :string)
      arg(:line2, :string)
      arg(:line3, :string)
      arg(:city, non_null(:string))
      arg(:postcode, non_null(:string))
      arg(:country, non_null(:string))

      resolve(Utils.handle_errors(&AddressResolver.create_address/3))
    end
  end
end
