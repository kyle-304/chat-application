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
    query = ContactList.Query.from_user(user_id)
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
end
