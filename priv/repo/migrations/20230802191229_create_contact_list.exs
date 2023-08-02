defmodule Chat.Repo.Migrations.CreateContactList do
  use Ecto.Migration

  def change do
    create table(:contact_lists, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :list, {:array, :string}, default: []
      add :user_id, references(:user, type: :binary_id)

      timestamps()
    end

    create index(:contact_lists, [:user_id])
  end
end
