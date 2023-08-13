defmodule Chat.Repo.Migrations.CreatePrivateMessages do
  use Ecto.Migration

  def change do
    create table(:private_messages, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:text, :text, null: false)
      add(:sender_id, :string, null: false)
      add(:receiver_id, :string, null: false)
      add(:private_chat_id, references(:private_chats, type: :binary_id))

      timestamps()
    end

    create(index(:private_messages, [:private_chat_id]))
  end
end
