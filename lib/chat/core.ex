defmodule Chat.Core do
  @moduledoc """
  Main API for the Core Context
  """

  alias Chat.Accounts.User
  alias Chat.Accounts.Profile
  alias Chat.Core.ContactList
  alias Chat.Core.PrivateChat

  @doc """
  Creates a new contact list for a user
  """
  @spec create_contact_list(user :: User.t()) :: ContactList.t()
  def create_contact_list(list \\ %ContactList{}, %{id: user_id}) do
    changeset = ContactList.creation_changeset(list, %{user_id: user_id})
    Chat.Repo.insert(changeset)
  end

  @doc """
  Returns all the users within the system as possible contacts
  """
  @spec all_contacts() :: [Profile.t()] | []
  def all_contacts do
    Chat.Repo.all(Profile)
  end

  @doc """
  Returns a list of all the users in the user's contact list
  """
  @spec contacts_for_user(user :: User.t()) :: [Profile.t()] | []
  def contacts_for_user(user) do
    contact_list = contact_list_for_user(user)
    fetch_contacts_from_contact_list(contact_list)
  end

  defp contact_list_for_user(%{id: user_id}) do
    query = ContactList.Query.from_user_id(user_id)
    Chat.Repo.one!(query)
  end

  defp fetch_contacts_from_contact_list(%{list: contact_user_ids}) do
    query = Profile.Query.from_user_ids(contact_user_ids)
    Chat.Repo.all(query)
  end

  @doc """
  Returns a list of users with their profiles preloaded given a list
  of user ids
  """
  @spec users_from_ids(user_ids :: list(String.t())) :: list(User.t()) | []
  def users_from_ids(user_ids) when is_list(user_ids) do
    query = user_from_ids_query(user_ids)
    Chat.Repo.all(query)
  end

  defp user_from_ids_query(user_ids) do
    user_ids
    |> User.Query.from_user_ids()
    |> User.Query.preload_profile()
  end

  @doc """
  Returns true or false on whether a user with a given id exists
  """
  @spec user_exists?(user_id :: String.t()) :: true | false
  def user_exists?(user_id) do
    query = User.Query.from_user_id(user_id)
    Chat.Repo.exists?(query)
  end

  @doc """
  Returns a list of users with the given email or phone number
  """
  @spec search_contacts(search :: String.t()) :: [Profile.t()] | []
  def search_contacts(search) do
    if Regex.match?(~r/@/, search), do: search_by_email(search), else: search_by_phone(search)
  end

  defp search_by_email(email) when is_binary(email) do
    query = Profile.Query.email_similar_to(email)
    Chat.Repo.all(query)
  end

  defp search_by_phone(phone_number) when is_binary(phone_number) do
    query = Profile.Query.phone_similar_to(phone_number)
    Chat.Repo.all(query)
  end

  @doc """
  Adds a given user to the contact list of another user
  """
  @spec add_to_user_contacts_list(user :: User.t(), user_id :: String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def add_to_user_contacts_list(user, user_id) do
    with contact_list <- contact_list_from_user!(user),
         {:ok, _updated} <- add_to_contact_list(contact_list, user_id) do
      {:ok, user}
    end
  end

  defp add_to_contact_list(contact_list, user_id) do
    changeset = ContactList.add_contact_changeset(contact_list, %{contact_user_id: user_id})
    Chat.Repo.update(changeset)
  end

  @doc """
  Returns the contact list for a user given the user
  """
  @spec contact_list_from_user!(user :: User.t()) :: ContactList.t()
  def contact_list_from_user!(%{id: user_id}) do
    query = ContactList.Query.from_user_id(user_id)
    Chat.Repo.one!(query)
  end

  @doc """
  Removes a given user from a user's contact list
  """
  @spec remove_from_user_contacts(user :: User.t(), user_id :: String.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def remove_from_user_contacts(user, user_id) do
    with contact_list <- contact_list_from_user!(user),
         {:ok, _contacts} <- remove_from_contact_list(contact_list, user_id) do
      {:ok, user}
    end
  end

  defp remove_from_contact_list(contact_list, user_id) do
    changeset = ContactList.remove_contact_changeset(contact_list, %{contact_user_id: user_id})
    Chat.Repo.update(changeset)
  end

  @doc """
  Returns a list of private messages for the user identified by the provided
  user id
  """
  @spec private_chats_for_user(user :: User.t()) :: list(PrivateChat.t()) | []
  def private_chats_for_user(%{id: user_id}) do
    query = PrivateChat.Query.from_user_id(user_id)
    Chat.Repo.all(query)
  end

  @doc """
  Starts a private chat between the current user and the user who is the receiver
  of the message

  It first checks to ensure that there's a chat between the two user and if
  it exists, it returns the chat. If not, it creates the chat between the two
  users and returns it
  """
  @spec start_private_chat(current_user :: User.t(), receiver_id :: String.t()) ::
          {:ok, PrivateChat.t()} | {:error, Ecto.Changeset.t()}
  def start_private_chat(current_user, receiver_id) do
    identifiers = private_chat_identifiers(current_user, receiver_id)

    case private_chat_for_users(identifiers) do
      nil -> new_private_chat(current_user, receiver_id)
      private_chat -> fetch_messages(private_chat)
    end
  end

  defp private_chat_identifiers(%{id: sender_id}, receiver_id) do
    user_ids = [sender_id, receiver_id]
    PrivateChat.private_chat_identifiers(user_ids)
  end

  defp private_chat_for_users(identifier) when is_map(identifier) do
    query = PrivateChat.Query.from_identifiers(identifier)
    Chat.Repo.one(query)
  end

  defp new_private_chat(%{id: sender_id}, receiver_id, chat \\ %PrivateChat{}) do
    params = %{"user_ids" => [sender_id, receiver_id]}
    changeset = PrivateChat.creation_changeset(chat, params, current_user: sender_id)

    insert_private_chat_and_preload_messages(changeset)
  end

  defp insert_private_chat_and_preload_messages(changeset) do
    {:ok, private_chat} = Chat.Repo.insert(changeset)
    {:ok, fetch_messages(private_chat)}
  end

  defp fetch_messages(private_chat) do
    Chat.Repo.preload(private_chat, [:private_messages])
  end
end
