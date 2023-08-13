defmodule ChatWeb.User.ChatsLive do
  @moduledoc """
  Live module for the chat functionality
  """
  use ChatWeb, :live_view

  alias Chat.Core
  alias ChatWeb.Endpoint

  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  @impl LiveView
  def mount(_params, _session, socket) do
    if connected?(socket), do: subscribe_to_chats(socket)
    {:ok, stream_configure(socket, :private_chats, dom_id: & &1.id)}
  end

  defp subscribe_to_chats(%{assigns: %{current_user: user}}) do
    private_chats = Core.private_chats_for_user(user)
    for chat <- private_chats, do: Endpoint.subscribe(chat.id)
  end

  @impl LiveView
  def handle_params(%{"receiver" => _reciever_id}, _url, socket) do
    {:noreply, socket}
  end

  @impl LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, assign_private_chats(socket)}
  end

  defp assign_private_chats(%{assigns: %{current_user: user}} = socket) do
    private_chats = Core.private_chats_for_user(user)
    stream(socket, :private_chats, private_chats)
  end
end
