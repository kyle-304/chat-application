defmodule Chat.Repo.Migrations.Chat do
  use Ecto.Migration

  def change do
    create table(:chats, primary_key: false) do
      add :id, :binary_id, primary_key: true

      timestamps()
    end
  end
end
