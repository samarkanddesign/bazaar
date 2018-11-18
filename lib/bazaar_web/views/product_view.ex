defmodule BazaarWeb.ProductView do
  use BazaarWeb, :view

  def format_price(price) do
    (price / 100)
    |> Float.round(2)
  end

  def thumbnail_url(product, size \\ :show) do
    case Bazaar.Product.featured_image(product) do
      nil ->
        dims =
          Bazaar.Uploaders.ProductImage.sizes()
          |> Map.get(size, "350")

        "https://via.placeholder.com/" <> dims

      product_image ->
        Bazaar.Uploaders.ProductImage.url({product_image.image, product_image}, size)
    end
  end
end
