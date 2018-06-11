# Bazaar

_The graphql api for the Samarkand Store_

## Runinng in dev:

* Install dependencies with `mix deps.get`
* Run the local database with `docker-compose up`
* Create and migrate your database with `mix ecto.create && mix ecto.migrate`
* Optionally seed the database with some dummy data with `mix run priv/repo/seeds.exs`
* Start Phoenix endpoint with `mix phx.server`

Bazaar has [graphiql](https://github.com/graphql/graphiql) enabled which will allow you explore the api with autocompletion and documentation.

You can visit [`localhost:4000/graphiql`](http://localhost:4000/graphiql) from your browser.
