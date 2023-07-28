defmodule Chat.Repo.Migrations.Messages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :text
      add :status, :string
      # add :sender_id, :string
      add :time_stamp, :time
      add :chat_id, references(:chats, type: :binary_id, on_delete: :delete_all)
      add :sender_id, references(:users, type: :binary_id)

      timestamps()
    end

    create index(:messages, [:chat_id])
    create index(:messages, [:sender_id])
  end
end
