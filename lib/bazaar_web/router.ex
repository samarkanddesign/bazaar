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

  pipeline :graphql do
    plug(Bazaar.Auth.Pipeline)
    plug(Bazaar.Context)
  end

  scope "/", BazaarWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/shop", ProductController, :index)
    get("/shop/:id", ProductController, :show)
  end

  scope "/api", BazaarWeb do
    pipe_through(:api)
    post("/product_images", ProductImageController, :create)
  end

  scope "/" do
    pipe_through(:graphql)

    forward(
      "/graphiql",
      Absinthe.Plug.GraphiQL,
      schema: Bazaar.GraphQl.Schema,
      context: %{pubsub: Bazaar.Endpoint}
    )

    forward(
      "/graphql",
      Absinthe.Plug,
      schema: Bazaar.GraphQl.Schema,
      context: %{pubsub: Bazaar.Endpoint}
    )
  end

  # Other scopes may use custom stacks.
  # scope "/api", BazaarWeb do
  #   pipe_through :api
  # end
end
