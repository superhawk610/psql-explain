defmodule Seed.Seeders.Users do
  @moduledoc "Users seeder."

  alias Seed.Repo
  alias Seed.Models.User

  import Faker
  import Faker.Lorem
  import Faker.Person
  import Faker.Internet

  @count 100

  def seed do
    for _ <- 1..@count do
      params = %{
        email: email(),
        username: user_name(),
        first_name: first_name(),
        last_name: last_name(),
        posts: posts()
      }

      %User{}
      |> User.changeset(params)
      |> Repo.insert!()
    end
  end

  defp posts do
    for _ <- 1..random_between(0, 7) do
      %{
        title: sentence(),
        body: paragraphs() |> Enum.join("\n")
      }
    end
  end
end
