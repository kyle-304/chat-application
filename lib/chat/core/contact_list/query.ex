defmodule Chat.Core.ContactList.Query do
  @moduledoc """
  Defines query functions for working with the contact list schema and table
  """

  import Ecto.Query, warn: false

  alias Chat.Core.ContactList

  @typep queryable :: ContactList | Ecto.Queryable.t()

  @doc """
  Returns the nase queryable for the contact list
  """
  @spec base() :: ContactList | Ecto.Queryable.t()
  def base, do: ContactList

  @doc """
  Returns a query representing the contact list for a user identified
  by the provided id
  """
  @spec from_user(query :: queryable(), user_id :: String.t()) :: queryable()
  def from_user(query \\ base(), user_id) do
    where(query, [c], c.user_id == ^user_id)
  end
end
