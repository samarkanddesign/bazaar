use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :bazaar, BazaarWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :bcrypt_elixir, log_rounds: 4

# Configure your database
config :bazaar, Bazaar.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "secret",
  database: "bazaar_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
