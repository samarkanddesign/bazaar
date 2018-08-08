defmodule Bazaar.Services.StockKeeper do
  alias Bazaar.Order
  alias Bazaar.OrderItem
  alias Bazaar.Product
  alias Bazaar.Repo

  def update_stock(%Order{order_items: items}) do
    Enum.each(items, &update_stock_from_item/1)
  end

  defp update_stock_from_item(%OrderItem{product_id: product_id, quantity: quantity}) do
    case Repo.get(Product, product_id) do
      nil ->
        {:error, "product does not exist"}

      product ->
        product |> Product.changeset(%{stock_qty: product.stock_qty - quantity}) |> Repo.update()
    end
  end
end
