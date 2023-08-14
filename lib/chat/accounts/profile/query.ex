defmodule Chat.Accounts.Profile.Query do
  @moduledoc """
  Defines functions that returns queries for working with the profiles table
  """

  import Ecto.Query, warn: false

  alias Chat.Accounts.Profile

  @typep queryable :: Profile.t() | Ecto.Queryable.t()

  @doc "Returns the base query for working with profiles table"
  @spec base() :: queryable()
  def base, do: Profile

  @doc """
  Returns a query for the profiles whose user_ids are in the provided list of ids
  """
  @spec from_user_ids(query :: queryable(), ids :: [String.t()]) :: queryable()
  def from_user_ids(query \\ base(), ids) when is_list(ids) do
    where(query, [p], p.user_id in ^ids)
  end

  @doc """
  Returns a query for the profile where the profiles' first or last names
  are similarto the one provided
  """
  @spec names_similar_to(query :: queryable(), name :: String.t()) :: queryable()
  def names_similar_to(query \\ base(), name) do
    where(query, [p], ilike(p.first_name, ^"#{name}%") or ilike(p.last_name, ^"#{name}%"))
  end
end
