defmodule Chat.Core do
  @moduledoc """
  Main API for the Core Context
  """

  alias Chat.Accounts.User
  alias Chat.Accounts.Profile
  alias Chat.Core.ContactList

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
end
