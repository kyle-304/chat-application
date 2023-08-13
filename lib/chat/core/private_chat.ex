defmodule Chat.Core.PrivateChat do
  @moduledoc """
  This module holds the chat information for at most two people
  within the system.

  For a private chat to exist, there must be two users in the chat
  and once created. A chat cannot be deleted from the system
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Chat.Core
  alias Chat.Core.PrivateMessage

  alias Ecto.Changeset

  @typedoc """
  Type for a single participant
  """
  @type participant :: %{
          id: String.t(),
          full_name: String.t(),
          profile_image: String.t() | nil
        }

  @type t :: %__MODULE__{
          id: String.t() | nil,
          user_ids: list(String.t()) | [],
          identifiers: list(String.t()) | [],
          updated_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil,
          participants: list(participant()) | nil
        }

  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "private_chats" do
    field(:identifiers, {:array, :string})
    field(:user_ids, {:array, :string})
    field(:participants, {:array, :map})
    has_many(:private_messages, PrivateMessage)

    timestamps()
  end

  @doc """
  Returns the changeset to be used for the creation of a new chat

  In order for a chat to be valid, it must contain at most two
  user ids representing the participants and the user ids must be
  validly registered within the system

  The third argument should be a keyword list that contains the user id of
  the currently logged in user so that, we can exclude its validation when
  ensuring the user exists.

  The id should be stored in the key `:current_user` and must be string
  """
  @spec creation_changeset(chat :: t() | Changeset.t(), attrs :: map(), opts :: Keyword.t()) ::
          Changeset.t()
  def creation_changeset(chat, attrs, opts) do
    chat
    |> cast(attrs, [:user_ids])
    |> validate_required([:user_ids])
    |> validate_user_ids(opts)
    |> put_chat_participants()
    |> put_private_chat_identifiers()
  end

  defp validate_user_ids(%{valid?: false} = changeset, _opts) do
    changeset
  end

  defp validate_user_ids(%{changes: %{user_ids: ids}} = changeset, _opts) when length(ids) != 2 do
    add_error(changeset, :user_ids, "a private chat can only be started between two users")
  end

  defp validate_user_ids(%{changes: %{user_ids: ids}} = changeset, opts) do
    [receiver_id] = Enum.reject(ids, &(&1 == opts[:current_user]))
    if Core.user_exists?(receiver_id), do: changeset, else: add_not_found_error(changeset)
  end

  defp add_not_found_error(changeset) do
    add_error(changeset, :user_ids, "recipient does not exist")
  end

  defp put_chat_participants(%{valid?: false} = changeset) do
    changeset
  end

  defp put_chat_participants(%{changes: %{user_ids: ids}} = changeset) do
    users = Core.users_from_ids(ids)
    participants = extract_participants(users)

    put_change(changeset, :participants, participants)
  end

  defp extract_participants(users) when is_list(users) do
    for %{id: id, profile: profile} <- users do
      %{
        id: id,
        full_name: full_name(profile),
        profile_image: profile.profile_image
      }
    end
  end

  defp full_name(%{first_name: f_name, last_name: l_name}) do
    "#{f_name} #{l_name}"
  end

  defp put_private_chat_identifiers(%{valid?: false} = changeset) do
    changeset
  end

  defp put_private_chat_identifiers(%{changes: %{user_ids: ids}} = changeset) do
    identifiers = private_chat_identifiers(ids)
    put_change(changeset, :identifiers, Map.values(identifiers))
  end

  @doc """
  Given a list of two ids, it returns the identifier of a possible
  existing chat.

  Because this is a list, it returns a map with identifiers formed from
  both combinations

  ## Example
  iex> private_chat_identifiers([user_id1, user_id2])
  %{
    identifier1: "user_id1::user_id1"
    identifier2: "user_id2::user_id1"
  }
  """
  @spec private_chat_identifiers(user_ids :: list(String.t())) :: %{
          identifier1: String.t(),
          identifier2: String.t()
        }
  def private_chat_identifiers(user_ids) when is_list(user_ids) and length(user_ids) == 2 do
    [first_id, second_id] = user_ids
    %{identifier1: "#{first_id}::#{second_id}", identifier2: "#{second_id}::#{first_id}"}
  end
end
