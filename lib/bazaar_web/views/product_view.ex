defmodule BazaarWeb.ProductView do
  use BazaarWeb, :view

  def format_price(price) do
    (price / 100)
    |> Float.round(2)
  end
end
