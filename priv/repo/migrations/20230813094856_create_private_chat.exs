defmodule Chat.Repo.Migrations.CreatePrivateChat do
  use Ecto.Migration

  def change do
    create table(:private_chats, primary_key: false) do
      add(:id, :binary_id, primary_key: true)
      add(:user_ids, {:array, :string}, null: false)
      add(:participants, {:array, :map}, null: false)

      timestamps()
    end
  end
end
