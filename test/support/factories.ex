defmodule Bazaar.Factory do
  use ExMachina.Ecto, repo: Bazaar.Repo

  def product_factory do
    name = sequence(:name, &"product-#{&1}")

    %Bazaar.Product{
      name: name,
      description: "It is a nice product",
      slug: name,
      status: "published",
      sku: name,
      price: 100,
      stock_qty: 10,
      featured: false,
      listed: true
    }
  end

  def basket_factory do
    %Bazaar.Basket{
      basket_id: sequence(:basket_id, &"basket-#{&1}")
    }
  end

  def basket_item_factory do
    %Bazaar.BasketItem{
      basket: build(:basket),
      product: build(:product),
      quantity: 1
    }
  end
end
