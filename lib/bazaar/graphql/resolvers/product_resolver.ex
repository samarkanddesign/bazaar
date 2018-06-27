defmodule Bazaar.GraphQl.Resolvers.ProductResolver do
  import Ecto.Query
  alias Bazaar.Product
  alias Bazaar.Repo

  def all(_root, args, _info) do
    page =
      Product
      |> order_by(desc: :inserted_at)
      |> preload(:categories)
      |> preload(:product_images)
      |> Repo.paginate(page: Map.get(args, :page, 1))

    {:ok,
     %{
       items: page.entries,
       pagination: %{
         page_number: page.page_number,
         page_size: page.page_size,
         total_pages: page.total_pages,
         total_entries: page.total_entries
       }
     }}
  end

  def get(_root, %{id: id}, _info) do
    {:ok,
     Repo.get(Product, id)
     |> Repo.preload(:categories)
     |> Repo.preload(:product_images)}
  end

  def get(_root, %{slug: slug}, _info) do
    {:ok,
     Repo.get_by(Product, slug: slug)
     |> Repo.preload(:categories)
     |> Repo.preload(:product_images)}
  end

  def get(_root, _args, _info) do
    {:error, "An 'id' or 'slug' argument must be provided"}
  end

  def create(_root, args, _info) do
    Product.changeset(%Product{}, args)
    |> Repo.insert()
  end

  def product_images(_root, _args, context) do
    product = context.source

    {:ok,
     Enum.map(product.product_images, fn image ->
       %{
         id: image.id,
         url: product_image_url(image)
       }
     end)}
  end

  def thumbnail(_root, _args, %{source: product}) do
    case Enum.at(product.product_images, 0) do
      nil -> {:ok, nil}
      image -> {:ok, %{id: image.id, url: product_image_url(image, :thumb)}}
    end
  end

  def base_url do
    BazaarWeb.Endpoint.struct_url()
    |> URI.to_string()
    |> URI.parse()
  end

  def product_image_url(product_image, size \\ :show) do
    base_url()
    |> URI.merge(Bazaar.Uploaders.ProductImage.url({product_image.image, product_image}, size))
    |> URI.to_string()
  end
end
