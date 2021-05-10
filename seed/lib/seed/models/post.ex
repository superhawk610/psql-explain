defmodule Seed.Models.Post do
  @moduledoc "Post schema."

  use Ecto.Schema

  alias Seed.Models.User

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "posts" do
    field(:title, :string)
    field(:body, :string)

    belongs_to(:user, User)

    timestamps()
  end

  @spec changeset(__MODULE__.t(), map()) :: Ecto.Changeset.t()
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:title, :body, :user_id])
    |> validate_required([:title, :body])
  end
end
