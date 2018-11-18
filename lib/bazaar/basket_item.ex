defmodule Bazaar.BasketItem do
  use Ecto.Schema
  import Ecto.Changeset

  alias Bazaar.{BasketItem, Product, Repo}

  schema "basket_items" do
    field(:quantity, :integer)

    belongs_to(:basket, Bazaar.Basket, type: :binary_id)
    belongs_to(:product, Bazaar.Product)

    timestamps()
  end

  def changeset(basket, attrs) do
    basket
    |> cast(attrs, [:basket_id, :quantity, :product_id])
    |> unique_constraint(:product, name: :basket_items_basket_id_product_id_unique)
    |> foreign_key_constraint(:product_id)
    |> foreign_key_constraint(:basket_id)
    |> validate_required([:product_id, :basket_id])
    |> ensure_enough_stock
  end

  def ensure_enough_stock(changeset) do
    product_id = get_field(changeset, :product_id)
    quantity = get_field(changeset, :quantity)

    case Repo.get_by(Product, %{id: product_id, listed: true}) do
      nil ->
        add_error(changeset, :product, "is not available for purchase")

      product ->
        case product.stock_qty do
          qty_in_stock when qty_in_stock < quantity ->
            add_error(changeset, :quantity, "is too high")

          _ ->
            changeset
        end
    end
  end

  def add_item_to_basket(
        basket_id,
        %{product_id: product_id, quantity: quantity}
      ) do
    item = get_basket_item(basket_id, product_id)

    BasketItem.changeset(item, %{
      quantity: item.quantity + quantity,
      product_id: product_id,
      basket_id: basket_id
    })
    |> Repo.insert_or_update()
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
