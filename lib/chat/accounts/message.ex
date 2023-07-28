defmodule Chat.Accounts.Message do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :text, :string
    field :status, :string
    # field :sender_id, :string
    belongs_to :chat, Chat.Accounts.Chat
    belongs_to :user, Chat.Accounts.User, foreign_key: :sender_id, references: :id

    timestamps()
  end
end
