defmodule BazaarWeb.PageController do
  use BazaarWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
