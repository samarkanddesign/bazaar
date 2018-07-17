defmodule Bazaar.GraphQl.Resolvers.BasketResolver do
  alias Bazaar.Repo
  alias Bazaar.Product
  alias Bazaar.BasketItem
  alias Bazaar.Basket

  def add_item_to_basket(
        _root,
        %{basket_id: basket_id, product_id: product_id, quantity: quantity},
        _info
      ) do
    case Repo.get_by(Product, %{id: product_id, listed: true}) do
      nil ->
        {:error,
         "Cannot add product to basket. Either it does not exist or is not available for purchase."}

      _ ->
        basket = get_basket(basket_id)
        item = get_basket_item(basket.id, String.to_integer(product_id))

        BasketItem.changeset(item, %{quantity: item.quantity + quantity})
        |> Repo.insert_or_update!()

        result = basket |> Repo.preload(basket_items: :product)

        {:ok, result}
    end
  end

  defp get_basket(basket_id) do
    case Repo.get_by(Basket, %{basket_id: basket_id}) do
      nil -> %Basket{basket_id: basket_id}
      b -> b
    end
    |> Basket.changeset(%{})
    |> Repo.insert_or_update!()
  end

  defp get_basket_item(basket_id, product_id) do
    case Repo.get_by(BasketItem, %{basket_id: basket_id, product_id: product_id}) do
      nil ->
        %BasketItem{
          basket_id: basket_id,
          product_id: product_id,
          quantity: 0
        }

      i ->
        i
    end
  end
end
