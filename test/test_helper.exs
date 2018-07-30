{:ok, _} = Application.ensure_all_started(:ex_machina)
Absinthe.Test.prime(Bazaar.GraphQl.Schema)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Bazaar.Repo, :manual)
