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
        basket =
          case Repo.get_by(Basket, %{basket_id: basket_id}) do
            nil -> %Basket{basket_id: basket_id}
            b -> b
          end
          |> Basket.changeset(%{})
          |> Repo.insert_or_update!()

        item =
          case Repo.get_by(BasketItem, %{basket_id: basket.id, product_id: product_id}) do
            nil ->
              %BasketItem{
                basket_id: basket.id,
                product_id: product_id,
                quantity: 0
              }

            i ->
              i
          end

        BasketItem.changeset(item, %{quantity: item.quantity + quantity})
        |> Repo.insert_or_update!()

        {:ok, basket |> Repo.preload(:basket_items)}
    end
  end
end
