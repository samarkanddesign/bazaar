defmodule BazaarWeb.ProductController do
  use BazaarWeb, :controller
  alias Bazaar.Product

  def index(conn, params) do
    products = Product.list(params)
    render(conn, "index.html", products: products)
  end
end
