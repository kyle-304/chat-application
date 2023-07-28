defmodule Chat.Repo.Migrations.Chatuser do
  use Ecto.Migration

  def change do
    create table(:chatusers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, type: :binary_id)
      add :chat_id, references(:chats, type: :binary_id)
    end

    create unique_index(:chatusers, [:user_id, :chat_id])
  end
end
