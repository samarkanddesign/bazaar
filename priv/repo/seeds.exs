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

Repo.delete_all(Bazaar.Role)
Repo.delete_all(Bazaar.User)
Repo.delete_all(Bazaar.Product)

admin_role =
  Repo.insert!(%Bazaar.Role{
    slug: "admin",
    name: "Admin"
  })

admin_user =
  Repo.insert!(%Bazaar.User{
    name: "Admin",
    email: "test@samarkanddesign.com",
    password_hash: "$2a$04$6WxbBxHvlhDIShEswSUxYOG7UEYEHUPpwVt9tcfCxJokYQc.yKHDi",
    role_id: admin_role.id
  })

Bazaar.Repo.insert!(%Bazaar.Product{
  name: "Awesome product",
  slug: "awesome-product",
  description: "This is an awesome product",
  price: 2250,
  sku: "AP1",
  stock_qty: 10,
  user_id: admin_user.id
})

Bazaar.Repo.insert!(%Bazaar.Product{
  name: "Average product",
  slug: "average-product",
  description: "This is an average product",
  price: 1050,
  sku: "AV1",
  stock_qty: 5,
  user_id: admin_user.id
})
