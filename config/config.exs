# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :logger, level: :info

config :authority_ecto, ecto_repos: [Authority.Ecto.Test.Repo]

config :authority_ecto, Authority.Ecto.Test.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "authority_ecto_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  priv: "test/support/"