defmodule Seed.Models.User do
  @moduledoc "User schema."

  use Ecto.Schema

  alias Seed.Models.Post

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "users" do
    field(:username, :string)
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)

    has_many(:posts, Post)

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:username, :email, :first_name, :last_name])
    |> cast_assoc(:posts)
    |> validate_required([:username, :email])
  end
end
