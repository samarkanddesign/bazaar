defmodule Bazaar.GraphQl.Resolvers.BasketResolver do
  alias Bazaar.Repo
  alias Bazaar.Product
  alias Bazaar.BasketItem
  alias Bazaar.Basket

  def get_basket(_root, %{basket_id: basket_id}, _context) do
    basket =
      case Repo.get_by(Basket, %{basket_id: basket_id}) do
        nil -> get_basket(basket_id)
        basket -> basket
      end

    {:ok, basket}
  end

  def add_item_to_basket(
        _root,
        %{basket_id: basket_id, product_id: product_id, quantity: quantity},
        _info
      ) do
    case Repo.get_by(Product, %{id: product_id, listed: true}) do
      nil ->
        {:error,
         "Cannot add product to basket. Either it does not exist or is not available for purchase."}

      product ->
        basket = get_basket(basket_id)
        item = get_basket_item(basket.id, product_id)
        current_quantity_in_basket = item.quantity

        case product.stock_qty do
          qty when qty <= quantity + current_quantity_in_basket ->
            {:error, "There is not enough stock to add this to the basket"}

          _ ->
            BasketItem.changeset(item, %{quantity: item.quantity + quantity})
            |> Repo.insert_or_update!()

            result = basket

            {:ok, result}
        end
    end
  end

  def remove_item_from_basket(
        _root,
        %{basket_id: basket_id, item_id: item_id},
        _info
      ) do
    case Repo.get_by(Basket, %{basket_id: basket_id}) do
      nil ->
        {:error, "A basket with this ID does not exist"}

      basket ->
        case Repo.get_by(BasketItem, %{basket_id: basket.id, id: item_id}) do
          nil ->
            {:ok, basket}

          item ->
            Repo.delete!(item)
            {:ok, basket}
        end
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
