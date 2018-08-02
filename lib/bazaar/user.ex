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
    has_many(:addresses, Bazaar.Address)
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
  end

  def registration_changeset(model, params \\ %{}) do
    model
    |> cast(params, [:password, :name, :email])
    |> sanitize_email
    |> validate_required([:name, :email, :password])
    |> validate_length(:password, min: 8)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email, message: "already has an account")
    |> put_password_hash
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

  defp sanitize_email(changeset) do
    case changeset do
      %{changes: %{email: email}} ->
        changeset |> put_change(:email, String.downcase(email) |> String.trim())

      _ ->
        changeset
    end
  end

  defp put_password_hash(changeset) do
    case changeset do
      %{changes: %{password: pass}} ->
        changeset
        |> put_change(:password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
        |> delete_change(:password)

      _ ->
        changeset
    end
  end
end
