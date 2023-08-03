defmodule ChatWeb.User.ContactsLive do
  @moduledoc """
  Live module for viewing, searching and adding contact to users
  contact list
  """

  use ChatWeb, :live_view

  alias Chat.Core

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(params, _url, socket) do
    IO.inspect(socket.assigns.live_action)
    {:noreply, prepare_socket(socket)}
  end

  defp prepare_socket(%{assigns: %{current_user: user, live_action: :index}} = socket) do
    assign_user_contacts(socket, user)
  end

  defp prepare_socket(%{assigns: %{current_user: user, live_action: :all_contacts}} = socket) do
    assign_all_contacts(socket)
  end

  defp assign_user_contacts(socket, user) do
    contacts = Core.contacts_for_user(user)
    assign(socket, :contacts, contacts)
  end

  defp assign_all_contacts(socket) do
    contacts = Core.all_contacts()
    assign(socket, :contacts, contacts)
  end
end
