defmodule Bazaar.Schema.Types.Custom.UUID do
  use Absinthe.Schema.Notation

  alias Ecto.UUID

  @desc """
  The UUID scalar type represents a version 4 (random) UUID. Any binary not conforming to this format will be flagged.
  """
  scalar :uuid, name: "UUID" do
    serialize(&UUID.cast!/1)
    parse(&cast_uuid/1)
  end

  defp cast_uuid(%Absinthe.Blueprint.Input.String{value: value}) do
    UUID.cast(value)
  end

  defp cast_uuid(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp cast_uuid(_) do
    :error
  end
end
