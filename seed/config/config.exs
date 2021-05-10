use Mix.Config

config :seed, Seed.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "explain_demo",
  hostname: "localhost",
  username: "postgres",
  password: "postgres"

config :seed, ecto_repos: [Seed.Repo]

