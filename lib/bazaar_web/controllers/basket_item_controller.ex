defmodule BazaarWeb.BasketItemController do
  use BazaarWeb, :controller
  alias Bazaar.{Basket, Repo, BasketItem}

  def create(conn, %{"product_id" => product_id, "quantity" => quantity}) do
    basket_id =
      case get_session(conn, :basket_id) do
        nil -> create_basket() |> Map.get(:basket_id)
        b -> b
      end

    conn_with_basket = put_session(conn, :basket_id, basket_id)

    case BasketItem.add_item_to_basket(basket_id, %{product_id: product_id, quantity: quantity}) do
      {:ok, _} ->
        conn_with_basket
        |> put_status(201)
        |> text("ok")

      {:error, _changeset} ->
        conn_with_basket
        |> put_status(400)
        |> text("error")
    end
  end

  defp create_basket() do
    %Basket{} |> Basket.changeset(%{}) |> Repo.insert()
  end
end
