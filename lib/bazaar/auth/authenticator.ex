defmodule Bazaar.Authenticator do
  alias Bazaar.User

  def authenticate(%{email: email, password: password}) do
    user = Bazaar.Repo.get_by(User, email: String.downcase(email))

    case user do
      nil ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, "Invalid credentials"}

      _ ->
        case Comeonin.Bcrypt.checkpw(password, user.password_hash) do
          true -> {:ok, user}
          _ -> {:error, "Invalid credentials"}
        end
    end
  end
end
