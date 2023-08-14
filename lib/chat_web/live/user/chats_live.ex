defmodule ChatWeb.User.ChatsLive do
  @moduledoc """
  Live module for the chat functionality
  """
  alias ChatWeb.Layouts
  use ChatWeb, :live_view

  alias Chat.Core
  alias Chat.Core.PrivateMessage, as: Message
  alias ChatWeb.Endpoint

  alias Phoenix.LiveView

  @impl LiveView
  def mount(_params, _session, socket) do
    socket = configure_socket_streams(socket)
    opts = [layout: {Layouts, :chat}, temporary_assigns: [form: nil]]

    {:ok, assign_and_subscribe_to_private_chats(socket), opts}
  end

  defp configure_socket_streams(socket) do
    socket
    |> stream_configure(:private_chats, dom_id: & &1.id)
    |> stream_configure(:private_messages, dom_id: & &1.id)
  end

  defp assign_and_subscribe_to_private_chats(%{assigns: %{current_user: user}} = socket) do
    private_chats = private_chats_for_user(user)
    if connected?(socket), do: subscribe_to_chats(private_chats)

    stream(socket, :private_chats, private_chats)
  end

  defp private_chats_for_user(user) do
    private_chats = Core.private_chats_for_user(user)
    for chat <- private_chats, do: remove_current_user(chat, user)
  end

  defp remove_current_user(%{participants: participants} = chat, %{id: user_id}) do
    participants = for %{"id" => id} = user <- participants, id != user_id, do: user
    Map.put(chat, :participants, participants)
  end

  defp subscribe_to_chats(private_chats) when is_list(private_chats) do
    for chat <- private_chats, do: Endpoint.subscribe(chat.id)
  end

  @impl LiveView
  def handle_params(%{"receiver" => receiver_id}, _url, socket) do
    {:noreply, prepare_socket_for_messaging(socket, receiver_id)}
  end

  @impl LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, assign_private_chats(socket)}
  end

  defp assign_private_chats(%{assigns: %{current_user: user}} = socket) do
    private_chats = Core.private_chats_for_user(user)
    stream(socket, :private_chats, private_chats)
  end

  defp prepare_socket_for_messaging(socket, receiver_id) do
    socket
    |> add_message_form(receiver_id)
    |> assign_private_messages()
  end

  defp add_message_form(%{assigns: %{current_user: user}} = socket, receiver_id) do
    new_message = %Message{sender_id: user.id, receiver_id: receiver_id}
    changeset = Core.change_private_message(new_message)

    assign(socket, receiver_id: receiver_id, form: to_form(changeset, as: "message"))
  end

  defp assign_private_messages(
         %{assigns: %{receiver_id: receiver_id, current_user: user}} = socket
       ) do
    private_chat = Core.private_chat_for_users(user, receiver_id)

    socket
    |> assign(:private_chat_id, private_chat.id)
    |> stream(:private_messages, private_chat.private_messages, reset: true)
  end

  @impl LiveView
  def handle_event("send", %{"message" => params}, socket) do
    {:noreply, handle_send(socket, params)}
  end

  defp handle_send(socket, params) do
    params = new_message_params(socket, params)

    case Core.create_private_message(params) do
      {:ok, message} -> handle_send_success(socket, message)
      {:error, _changeset} -> put_flash(socket, :error, "unable to send message")
    end
  end

  defp new_message_params(
         %{assigns: %{receiver_id: r_id, current_user: user, private_chat_id: chat_id}},
         params
       ) do
    Map.merge(params, %{
      "sender_id" => user.id,
      "receiver_id" => r_id,
      "private_chat_id" => chat_id
    })
  end

  defp handle_send_success(%{assigns: %{private_chat_id: chat_id}} = socket, message) do
    Endpoint.broadcast(chat_id, "new_message", message)

    socket
    |> reset_form()
    |> stream_insert(:private_messages, message)
  end

  defp reset_form(%{assigns: %{receiver_id: receiver_id}} = socket) do
    add_message_form(socket, receiver_id)
  end

  @impl Phoenix.LiveView
  def handle_info(
        %{event: "new_message", payload: %{private_chat_id: pc_id} = msg},
        %{assigns: %{private_chat_id: chat_id}} = socket
      ) do
    socket = if pc_id == chat_id, do: display_message(socket, msg), else: socket
    {:noreply, socket}
  end

  defp display_message(socket, message) do
    stream_insert(socket, :private_messages, message)
  end

  # this function is used to determine the positioning of the message
  # based on the sender id and the id of the currenly logged in user
  defp placement_direction(%{sender_id: sender_id} = _msg, %{id: current_user_id} = _current_user) do
    if sender_id == current_user_id, do: "justify-end", else: "justify-start"
  end

  ## sets the background color of the messages based on whether the message
  # sender id is same as the current user id
  defp message_color(%{sender_id: sender_id} = _msg, %{id: current_user_id}) do
    if sender_id == current_user_id, do: "bg-blue-500", else: "bg-green-500"
  end
end
