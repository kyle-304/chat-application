defmodule Chat.Accounts.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chat.Accounts.User
  alias Chat.Accounts.Chatuser

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "chats" do
    has_many :messages, Chat.Accounts.Message
    many_to_many :users, User, join_through: Chatuser

    timestamps()
  end
end
