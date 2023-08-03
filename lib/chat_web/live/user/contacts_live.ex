defmodule ChatWeb.User.ContactsLive do
  @moduledoc """
  Live module for viewing, searching and adding contact to users
  contact list
  """

  use ChatWeb, :live_view

  alias Chat.Core

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign_contact_ids(socket)}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    {:noreply, prepare_socket(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("add_to_contacts", %{"user_id" => user_id}, socket) do
    {:noreply, handle_add_to_contacts(socket, user_id)}
  end

  def handle_event("remove_contact", %{"user_id" => user_id}, socket) do
    {:noreply, handle_remove_from_contacts(socket, user_id)}
  end

  defp assign_contact_ids(%{assigns: %{current_user: user}} = socket) do
    contacts = Core.contacts_for_user(user)
    contact_ids = Enum.map(contacts, & &1.user_id)
    assign(socket, :contact_ids, contact_ids)
  end

  defp prepare_socket(%{assigns: %{current_user: user, live_action: :index}} = socket) do
    assign_user_contacts(socket, user)
  end

  defp prepare_socket(%{assigns: %{current_user: user, live_action: :all_contacts}} = socket) do
    assign_all_contacts(socket)
  end

  defp assign_user_contacts(socket, user) do
    contacts = Core.contacts_for_user(user)
    assign(socket, contacts: contacts)
  end

  defp assign_all_contacts(socket) do
    contacts = Core.all_contacts()
    assign(socket, :contacts, contacts)
  end

  # Handle add to contact
  defp handle_add_to_contacts(%{assigns: %{current_user: user}} = socket, user_id) do
    case Core.add_to_user_contacts_list(user, user_id) do
      {:ok, _} -> handle_add_success(socket, user_id)
      {:error, _} -> put_flash(socket, :error, "Could not add user to contacts")
    end
  end

  defp handle_add_success(%{assigns: %{contact_ids: con_ids}} = socket, user_id) do
    socket
    |> assign(:contact_ids, [user_id | con_ids])
    |> put_flash(:info, "User added successfully")
  end

  # Handle remove from contacts
  defp handle_remove_from_contacts(%{assigns: %{current_user: user}} = socket, user_id) do
    case Core.remove_from_user_contacts(user, user_id) do
      {:ok, _} -> handle_removal_success(socket, user_id)
      {:error, _} -> put_flash(socket, :error, "Could not remove user from contacts")
    end
  end

  defp handle_removal_success(socket, user_id) do
    socket
    |> update_contacts_details(user_id)
    |> put_flash(:info, "User removed from contacts successfully")
  end

  defp update_contacts_details(
         %{assigns: %{contact_ids: con_ids, contacts: cons}} = socket,
         user_id
       ) do
    socket
    |> assign(:contact_ids, List.delete(con_ids, user_id))
    |> assign(:contacts, Enum.reject(cons, &(&1.user_id == user_id)))
  end

  # Functions to be used within the html file

  @doc """
  Given a user id, it checks whether the user id is part of the contact and if so
  returns correct message
  """
  def display_message(contact_ids, user_id) when is_list(contact_ids) do
    if user_id in contact_ids, do: "Added to contacts", else: "Add as contact"
  end

  @doc """
  Returns whether or not add button is disabled
  """
  def add_button_disabled?(contact_ids, user_id) when is_list(contact_ids) do
    user_id in contact_ids
  end
end
