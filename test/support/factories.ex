defmodule Bazaar.Factory do
  use ExMachina.Ecto, repo: Bazaar.Repo

  def user_factory do
    name = sequence(:name, &"user-#{&1}")

    %Bazaar.User{
      name: name,
      email: "#{name}@example.com",
      password_hash: "$2b$12$CPX7zOfxY9ZfChhZtVP/..fivU/3rMHIMfyWaA7j5FU0acoyZ/xb6"
    }
  end

  def make_admin(user) do
    role = insert(:role, %{slug: "admin", name: "Admin"})
    %{user | role_id: role.id}
  end

  def role_factory do
    %Bazaar.Role{
      slug: sequence(:slug, &"role-#{&1}"),
      name: sequence(:name, &"Role-#{&1}"),
      description: "A role"
    }
  end

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
    %Bazaar.Basket{}
  end

  def basket_item_factory do
    %Bazaar.BasketItem{
      basket: build(:basket),
      product: build(:product),
      quantity: 1
    }
  end
end
