defmodule Bazaar.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:name, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)

    belongs_to(:role, Bazaar.Role)
    has_many(:products, Bazaar.Product)
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password])
    |> validate_required([:name, :email, :password])
  end

  def find_and_confirm_password(model, params \\ %{}) do
    changeset =
      model
      |> cast(params, [:email, :password])
      |> validate_required([:email, :password])

    case changeset do
      %{valid?: true, changes: credentials} ->
        case Bazaar.Authenticator.authenticate(credentials) do
          {:ok, user} -> {:ok, user}
          {:error, reason} -> {:error, add_error(changeset, :auth, reason), :invalid_creds}
        end

      _ ->
        {:error, changeset, :invalid_form}
    end
  end
end
