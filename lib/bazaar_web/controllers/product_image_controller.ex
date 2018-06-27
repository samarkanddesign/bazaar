defmodule BazaarWeb.ProductImageController do
  use BazaarWeb, :controller

  alias Bazaar.ProductImage
  alias Bazaar.Product
  alias Bazaar.Repo

  def index(conn, _) do
    images = Repo.all(ProductImage)
    render(conn, "index.html", images: images)
  end

  def new(conn, _) do
    changeset = ProductImage.changeset(%ProductImage{})
    products = Repo.all(Product) |> Enum.map(&{&1.name, &1.id})
    render(conn, "new.html", changeset: changeset, products: products)
  end

  def create(conn, params) do
    IO.inspect(params)

    changeset = ProductImage.changeset(%ProductImage{}, params)
    IO.inspect(changeset)

    case Repo.insert(changeset) do
      {:ok, _} ->
        conn
        |> put_status(201)
        |> text("ok")

      {:error, _changeset} ->
        conn
        |> put_status(400)
        |> text("error")
    end
  end
end
