defmodule Bazaar.GraphQl.Utils do
  def resolve_created_date(_root, _args, %{source: %{inserted_at: inserted_at}}) do
    {:ok, inserted_at}
  end

  def handle_errors(fun) do
    fn source, args, info ->
      case Absinthe.Resolution.call(fun, source, args, info) do
        {:error, %Ecto.Changeset{} = changeset} -> format_changeset(changeset)
        {:ok, entity} -> {:ok, %{entity: entity}}
        val -> val
      end
    end
  end

  def format_changeset(changeset) do
    errors =
      changeset.errors
      |> Enum.map(fn {key, error} ->
        %{key: key, reason: BazaarWeb.ErrorHelpers.translate_error(error)}
      end)

    {:ok, %{validation: errors}}
  end
end
