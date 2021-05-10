defmodule Seed do
  @moduledoc "Simple database seeder."

  use Application

  alias Seed.Seeders

  @seeders [Seeders.Users]

  def start(_type, _args) do
    children = [
      Seed.Repo
    ]

    # start deps
    Faker.start()

    opts = [strategy: :one_for_one, name: Seed.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def seed do
    for seeder <- @seeders do
      seeder.seed()
    end
  end
end
