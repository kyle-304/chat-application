defmodule Chat.Core.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chat.Accounts.User
  alias Chat.Core.Chatuser

  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "chats" do
    has_many :messages, Chat.Core.Message
    many_to_many :users, User, join_through: Chatuser

    timestamps()
  end
end
