# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :bazaar,
  ecto_repos: [Bazaar.Repo]

# Configures the endpoint
config :bazaar, BazaarWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bz5ZFiW6L61cRiNAe61TN+LAoYRONLm5Oo3FtykGRBy+VIzVAgDLFWpmMzBqyHWK",
  render_errors: [view: BazaarWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Bazaar.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :arc,
  storage: Arc.Storage.Local

config :bazaar, Bazaar.Auth.Guardian,
  issuer: "bazaar",
  secret_key: "dRBQrBk7K+7RRnvla+IZfTa1Wkynl9mTUNA3M9BBR8FOFjAySPB7ImdQFNoejF/y"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
