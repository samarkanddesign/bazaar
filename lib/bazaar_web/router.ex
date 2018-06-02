defmodule BazaarWeb.Router do
  use BazaarWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BazaarWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/" do
    forward(
      "/graphiql",
      Absinthe.Plug.GraphiQL,
      schema: Bazaar.GraphQl.Schema,
      context: %{pubsub: Bazaar.Endpoint}
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", BazaarWeb do
  #   pipe_through :api
  # end
end
