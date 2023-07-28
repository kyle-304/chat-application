defmodule Chat.Repo.Migrations.Profile do
  use Ecto.Migration

  def change do
    create table(:profiles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :phone_number, :string
      add :profile_image, :string
      add :user_id, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:profiles, [:phone_number])
    create unique_index(:profiles, [:user_id])
  end
end
