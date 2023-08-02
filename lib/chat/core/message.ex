defmodule Chat.Core.Message do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t() | nil,
          text: String.t() | nil,
          status: String.t() | nil,
          chat_id: String.t() | nil,
          sender_id: String.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "messages" do
    field :text, :string
    field :status, :string, default: "unread"
    belongs_to :chat, Chat.Core.Chat
    belongs_to :user, Chat.Accounts.User, foreign_key: :sender_id, references: :id

    timestamps()
  end

  @doc """
  Changeset for the creation of a new message
  """
  @spec creation_changeset(message :: Changeset.t() | t(), attrs :: map()) :: Changeset.t()
  def creation_changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :sender_id, :chat_id])
    |> validate_required([:text, :sender_id, :chat_id])
    |> foreign_key_constraint(:chat_id)
    |> foreign_key_constraint(:sender_id)
  end
end
