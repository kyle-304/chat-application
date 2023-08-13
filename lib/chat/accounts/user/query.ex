defmodule Chat.Accounts.User.Query do
  @moduledoc """
  Defines functions that returns queries for working with the users table
  """

  import Ecto.Query, warn: false

  alias Chat.Accounts.User

  @typep queryable :: User.t() | Ecto.Queryable.t()

  @doc "Returns the base query for working with users table"
  @spec base() :: queryable()
  def base, do: User

  @doc """
  Returns a query for users where the user has the provided id
  """
  @spec from_user_id(query :: queryable(), id :: String.t()) :: queryable()
  def from_user_id(query \\ base(), id) do
    where(query, [u], u.id == ^id)
  end

  @doc """
  Returns a query for the users where the users' ids are in the provided
  list of ids
  """
  @spec from_user_ids(query :: queryable(), ids :: [String.t()]) :: queryable()
  def from_user_ids(query \\ base(), ids) when is_list(ids) do
    where(query, [u], u.id in ^ids)
  end

  @doc """
  Returns a query for users in which the profile is preloaded
  """
  @spec preload_profile(query :: queryable()) :: queryable()
  def preload_profile(query \\ base()) do
    preload(query, [u], [:profile])
  end
end
