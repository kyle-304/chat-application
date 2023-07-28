defmodule Chat.Accounts.Chatuser do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "chatusers" do
    belongs_to :user, Chat.Accounts.User
    belongs_to :chat, Chat.Accounts.Chat

    timestamps()
  end
end
