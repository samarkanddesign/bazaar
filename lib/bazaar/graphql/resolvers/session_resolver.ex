defmodule Bazaar.GraphQl.Resolvers.SessionResolver do
  alias Bazaar.Repo
  alias Bazaar.User

  def login(_root, params, _info) do
    case User.find_and_confirm_password(%User{}, params) do
      {:ok, user} ->
        {:ok, jwt, _claims} = Bazaar.Auth.Guardian.encode_and_sign(user)
        {:ok, %{jwt: jwt, user: user}}

      {:error, _changeset, message} ->
        case message do
          :invalid_creds -> {:error, "Invalid credentials"}
          :invalid_form -> {:error, "Invalid form"}
        end
    end
  end

  def register(_root, params, _info) do
    case User.registration_changeset(%User{}, params)
         |> Repo.insert() do
      {:ok, user} ->
        {:ok, jwt, _claims} = Bazaar.Auth.Guardian.encode_and_sign(user)
        {:ok, %{jwt: jwt, user: user}}

      error ->
        IO.inspect(error)
        error
    end
  end
end
