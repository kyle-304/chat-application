defmodule Chat.Core.Chat.Query do
  @moduledoc """
  Returns queries for working with the Chat schema and "chats" table
  """

  import Ecto.Query, warn: false
  alias Chat.Core.Chat

  @typep queryable :: Chat.t() | Ecto.Queryable.t()

  @doc "returns the base query"
  @spec base() :: queryable()
  def base, do: Chat

  @doc """
  Returns a query for a chat where the users with the provided ids
  are participants
  """
  @spec from_user_id(query :: queryable(), user_id :: String.t()) :: queryable()
  def from_user_id(query \\ base(), user_id) do
    join(query, :left, [c], u in assoc(c, :users), on: u.id == ^user_id)
  end

  @doc """
  Returns a query for a chat where the users with the provided ids
  are participants
  """
  @spec from_user_ids(query :: queryable(), user_ids :: list(String.t())) :: queryable()
  def from_user_ids(query \\ base(), user_ids) do
    join(query, :left, [c], u in assoc(c, :users), on: u.id in ^user_ids)
  end

  @doc """
  Returns a query in which the users in the chats are preloaded
  """
  @spec preload_users(query :: queryable()) :: queryable()
  def preload_users(query \\ base()) do
    preload(query, [c], [:users])
  end
end
