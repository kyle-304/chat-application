defmodule ChatWeb.UserSettingsLive do
  @moduledoc """
  Live view for updadting the user profile
  """
  use ChatWeb, :live_view

  alias Chat.Core

  @impl Phoenix.LiveView
  def mount(_params, _session, %{assigns: %{current_user: user}} = socket) do
    {profile, changeset} = profile_changeset_for_user(user)
    {:ok, assign(socket, profile: profile, form: to_form(changeset, as: "profile"))}
  end

  defp profile_changeset_for_user(user) do
    user = Chat.Repo.preload(user, [:profile])
    {user.profile, Core.change_profile(user.profile)}
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"profile" => params}, socket) do
    {:noreply, handle_save_profile(socket, params)}
  end

  defp handle_save_profile(%{assigns: %{profile: profile}} = socket, params) do
    case Core.update_profile(profile, params) do
      {:ok, _profile} -> handle_success(socket)
      {:error, changeset} -> assign(socket, :changeset, changeset)
    end
  end

  defp handle_success(socket) do
    socket
    |> put_flash(:info, "profile updated successfully")
    |> push_navigate(to: ~p"/contacts")
  end
end
