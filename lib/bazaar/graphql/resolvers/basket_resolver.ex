defmodule Bazaar.GraphQl.Resolvers.BasketResolver do
  alias Bazaar.Repo
  alias Bazaar.Product
  alias Bazaar.BasketItem
  alias Bazaar.Basket

  def get_basket(_root, %{basket_id: basket_id}, _context) do
    {:ok, Repo.get(Basket, basket_id)}
  end

  def create_basket(_root, _, _context) do
    case %Basket{} |> Basket.changeset(%{}) |> Repo.insert() do
      {:ok, basket} -> {:ok, basket}
      _ -> {:error, "Could not create basket"}
    end
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
        case Ecto.UUID.cast(basket_id) do
          :error ->
            {:error, "invalid uuid"}

          {:ok, uuid} ->
            case Repo.get(Basket, uuid) do
              nil ->
                {:error, "basket does not exist"}

              basket ->
                item = get_basket_item(basket.id, product_id)
                current_quantity_in_basket = item.quantity

                case product.stock_qty do
                  qty_in_stock when qty_in_stock < quantity + current_quantity_in_basket ->
                    {:error, "There is not enough stock to add this to the basket"}

                  _ ->
                    BasketItem.changeset(item, %{quantity: item.quantity + quantity})
                    |> Repo.insert_or_update!()

                    result = basket

                    {:ok, result}
                end
            end
        end
    end
  end

  def remove_item_from_basket(
        _root,
        %{basket_id: basket_id, item_id: item_id},
        _info
      ) do
    case Repo.get_by(BasketItem, %{id: item_id, basket_id: basket_id}) do
      nil ->
        {:error, "This item does not exist in this basket"}

      item ->
        Repo.delete!(item)
        {:ok, Repo.get(Basket, basket_id)}
    end
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
