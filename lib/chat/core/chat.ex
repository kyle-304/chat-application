defmodule Chat.Core.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  alias Chat.Accounts.User
  alias Chat.Core.ChatUser

  alias Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          updated_at: NaiveDateTime.t(),
          inserted_at: NaiveDateTime.t()
        }

  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "chats" do
    has_many :messages, Chat.Core.Message
    many_to_many :users, User, join_through: ChatUser

    timestamps()
  end

  @doc """
  Creation changeset for new chat
  """
  @spec creation_changeset(chat :: t()) :: Changeset.t()
  def creation_changeset(chat) do
    change(chat)
  end
end
