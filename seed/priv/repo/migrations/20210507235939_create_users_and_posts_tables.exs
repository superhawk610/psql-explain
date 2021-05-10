defmodule Seed.Repo.Migrations.CreateUsersAndPostsTables do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string, null: false
      add :email, :string, null: false
      add :first_name, :string, null: false
      add :last_name, :string, null: false

      timestamps()
    end

    create table(:posts) do
      add :title, :string, null: false
      add :body, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
