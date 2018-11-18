defmodule BazaarWeb.ProductController do
  use BazaarWeb, :controller
  alias Bazaar.{Product, Repo}

  def index(conn, params) do
    products = Product.list(params)
    render(conn, "index.html", products: products)
  end

  def show(conn, %{"id" => slug}) do
    product = Repo.get_by!(Product, %{slug: slug})
    IO.inspect(product)
    render(conn, "show.html", product: product)
  end
end
