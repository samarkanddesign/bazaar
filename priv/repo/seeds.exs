# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bazaar.Repo.insert!(%Bazaar.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias Bazaar.Repo

defmodule Utils do
  def slugify(str) do
    str
    |> String.downcase()
    |> String.replace(" ", "-")
    |> String.replace(",", "")
    |> String.replace("&", "and")
  end
end

Faker.start()

Repo.delete_all(Bazaar.Product)
Repo.delete_all(Bazaar.User)
Repo.delete_all(Bazaar.Role)
Repo.delete_all(Bazaar.Category)

admin_role =
  Repo.insert!(%Bazaar.Role{
    slug: "admin",
    name: "Admin"
  })

admin_user =
  Repo.insert!(%Bazaar.User{
    name: "Bazaar Admin",
    email: "admin@samarkanddesign.com",
    password_hash: Comeonin.Bcrypt.hashpwsalt("secret"),
    role_id: admin_role.id
  })

normal_user =
  Repo.insert!(%Bazaar.User{
    name: "Bazaar User",
    email: "bazaar@samarkanddesign.com",
    password_hash: Comeonin.Bcrypt.hashpwsalt("secret")
  })

Repo.insert!(%Bazaar.Address{
  user_id: normal_user.id,
  phone: "+441234555666",
  city: "London",
  line1: "1 Nice Street",
  postcode: "SW1A 1AA",
  country: "GB"
})

categories =
  Enum.map(["Furnishings", "Lampshades", "Accessories"], fn cat ->
    Bazaar.Repo.insert!(%Bazaar.Category{
      term: cat,
      slug: Utils.slugify(cat)
    })
  end)

max_cat = Enum.count(categories) - 1

Enum.each(1..15, fn _ ->
  name = Faker.Commerce.product_name()
  sku = Faker.Lorem.characters(3..5) |> to_string |> String.upcase()
  related_cat = Enum.at(categories, Faker.random_between(0, max_cat))

  Bazaar.Repo.insert!(%Bazaar.Product{
    name: name,
    slug: Utils.slugify(name),
    description: Faker.Lorem.paragraph(),
    price: Faker.random_between(1, 200),
    sku: sku,
    stock_qty: Faker.random_between(0, 20),
    user_id: admin_user.id
  })
  |> Repo.preload(:categories)
  |> Ecto.Changeset.change()
  |> Ecto.Changeset.put_assoc(:categories, [related_cat])
  |> Repo.update!()
end)
