defmodule Chat.Core.Chatuser do
  @moduledoc """
  This module represent shte join table for the existing many to many relationship
  betweeen users and chats
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t() | nil,
          user_id: String.t() | nil,
          chat_id: String.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil
        }

  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "chatusers" do
    belongs_to :user, Chat.Accounts.User
    belongs_to :chat, Chat.Core.Chat

    timestamps()
  end

  @doc """
  Changeset for the creation of a new chat user r/ship
  """
  @spec creation_changeset(chat_user :: Changeset.t() | t(), attrs :: map()) :: Changeset.t()
  def creation_changeset(chat_user, attrs) do
    chat_user
    |> cast(attrs, [:user_id, :chat_id])
    |> validate_required([:user_id, :chat_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:chat_id)
    |> unique_constraint(:chat_id, name: "chat_user_unique_index")
  end
end
