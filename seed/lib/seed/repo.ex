defmodule Seed.Repo do
  @moduledoc false
  use Ecto.Repo,
    otp_app: :seed,
    adapter: Ecto.Adapters.Postgres
end

