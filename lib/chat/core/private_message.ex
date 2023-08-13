defmodule Chat.Core.PrivateMessage do
  @moduledoc """
  This module holds information about a private message sent in a private
  chat between two users
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Chat.Core.PrivateChat
  alias Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t() | nil,
          text: String.t() | nil,
          sender_id: String.t() | nil,
          receiver_id: String.t() | nil,
          updated_at: NaiveDateTime.t(),
          inserted_at: NaiveDateTime.t()
        }

  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "private_messages" do
    field(:text, :string)
    field(:sender_id, :string)
    field(:receiver_id, :string)
    belongs_to(:private_chat, PrivateChat)

    timestamps()
  end

  @doc """
  Returns changeset for the creation of a new private message
  """
  @spec creation_changeset(message :: t() | Changeset.t(), attrs :: map()) :: Changeset.t()
  def creation_changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :sender_id, :receiver_id])
    |> validate_required([:text, :sender_id, :receiver_id])
    |> foreign_key_constraint(:private_chat_id)
  end
end
