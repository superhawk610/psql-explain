defmodule Seed.MixProject do
  use Mix.Project

  def project do
    [
      app: :seed,
      version: "0.1.0",
      elixir: "~> 1.12-rc",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Seed, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.6"},
      {:ecto_sql, "~> 3.6"},
      {:faker, "~> 0.16"},
      {:postgrex, "~> 0.15"}
    ]
  end
end
