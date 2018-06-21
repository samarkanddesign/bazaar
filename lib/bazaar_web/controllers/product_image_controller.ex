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

  def create(conn, %{"product_image" => image_params}) do
    IO.inspect(image_params)
    # text(conn, "Uploaded")

    changeset = ProductImage.changeset(%ProductImage{}, image_params)
    IO.inspect(changeset)

    case Repo.insert(changeset) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Image was added")
        |> redirect(to: product_image_path(conn, :new))

      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> render("new.html", changeset: changeset)
    end
  end
end