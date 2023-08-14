defmodule Chat.Core.PrivateChat.Query do
  @moduledoc """
  Returns queries for working the "private_chats" db table and the
  PrivateMessage schema
  """
  import Ecto.Query, warn: false

  alias Chat.Core.PrivateChat

  @typep queryable :: Ecto.Queryable.t() | PrivateChat

  @doc """
  Returns the base for working with the "private_chats" table
  """
  @spec base() :: queryable()
  def base, do: PrivateChat

  @doc """
  Returns a query for the private chat where the provided user id
  participates in
  """
  @spec from_user_id(query :: queryable(), user_id :: String.t()) :: queryable()
  def from_user_id(query \\ base(), user_id) do
    query
    |> where([p], ^user_id in p.user_ids)
    |> preload([p], [:private_messages])
  end

  @doc """
  Returns a query for the private chat from the provided identifiers
  """
  @spec from_identifiers(query :: queryable(), identifiers :: map()) :: queryable()
  def from_identifiers(query \\ base(), %{identifier1: ident1, identifier2: ident2}) do
    query
    |> where([p], ^ident1 in p.identifiers and ^ident2 in p.identifiers)
    |> preload([p], [:private_messages])
  end
end
