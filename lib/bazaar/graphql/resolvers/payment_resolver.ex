defmodule Bazaar.GraphQl.Resolvers.PaymentResolver do
  alias Stripe
  alias Bazaar.Repo
  alias Bazaar.User

  def cards(_root, _args, %{context: %{current_user: user}}) do
    case user.billing_token do
      nil ->
        {:ok, []}

      id ->
        case Stripe.Customer.retrieve(id) do
          {:ok, customer} ->
            IO.inspect(customer)
            {:ok, customer.sources.data |> Enum.map(&translate_card/1)}

          err ->
            err
        end
    end
  end

  def cards(_root, _args, _info), do: {:error, "Unauthorized"}

  @doc """
  Save a card for a user that currently does not exist in Stripe
  """

  def save_card(_root, %{token: token}, %{
        context: %{current_user: %{billing_token: nil, email: email, id: id}}
      }) do
    case Stripe.Customer.create(%{source: token, description: "Customer for #{email}"}) do
      {:ok, customer} ->
        IO.inspect(customer)
        # TODO: make this async
        User.changeset(%User{id: id}, %{billing_token: customer.id}) |> Repo.update!()
        {:ok, %{cards: customer.sources.data |> Enum.map(&translate_card/1)}}

      {:error, %Stripe.Error{message: message}} ->
        {:ok, %{error: message}}

      err ->
        err
    end
  end

  def save_card(_root, %{token: token}, %{
        context: %{current_user: %{billing_token: billing_token}}
      }) do
    case Stripe.Card.create(%{customer: billing_token, source: token}) do
      {:ok, _} ->
        case Stripe.Customer.retrieve(billing_token) do
          {:ok, customer} ->
            {:ok, customer.sources.data |> Enum.map(&translate_card/1)}

          err ->
            err
        end

      err ->
        err
    end
  end

  def save_card(_root, _args, _info), do: {:error, "Unauthorized"}

  defp translate_card(card) do
    %{
      id: card.id,
      last_four: card.last4,
      brand: card.brand,
      funding: card.funding,
      exp_month: card.exp_month,
      exp_year: card.exp_year
    }
  end
end
