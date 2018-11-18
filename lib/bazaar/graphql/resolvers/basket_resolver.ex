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
    case BasketItem.add_item_to_basket(basket_id, %{product_id: product_id, quantity: quantity}) do
      {:ok, _} -> {:ok, Repo.get(Basket, basket_id)}
      err -> err
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
end
