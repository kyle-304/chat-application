defmodule Chat.Repo.Migrations.AddIdentifiersToPrivateChats do
  use Ecto.Migration

  def change do
    alter table(:private_chats) do
      add(:identifiers, {:array, :string}, null: false)
    end
  end
end
