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
   Returns a query for the profile where the profiles' email addresses are similar
   to the one provided
  """
  @spec email_similar_to(query :: queryable(), email :: String.t()) :: queryable()
  def email_similar_to(query \\ base(), email) do
    where(query, [p], ilike(p.email, ^"#{email}%"))
  end

  @doc """
   Returns a query for the profile where the profiles' phone numbers are similar
   to the one provided
  """
  @spec phone_similar_to(query :: queryable(), phone_number :: String.t()) :: queryable()
  def phone_similar_to(query \\ base(), phone_number) do
    where(query, [p], ilike(p.phone_number, ^"#{phone_number}%"))
  end
end
