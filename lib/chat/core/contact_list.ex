defmodule Chat.Core.ContactList do
  @moduledoc """
  Represents the users contact list
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t() | nil,
          list: [String.t()] | [],
          user_id: String.t() | nil,
          contact_user_id: String.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil
        }

  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "contact_lists" do
    field :contact_user_id, :string, virtual: true
    field :list, {:array, :string}, default: []
    belongs_to :user, Chat.Accounts.User

    timestamps()
  end

  @doc """
  Changeset for the creation of a new contact list
  """
  @spec creation_changeset(contact_list :: Changeset.t() | t(), attrs :: map()) :: Changeset.t()
  def creation_changeset(contact_list, attrs) do
    contact_list
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:user_id)
  end

  @doc """
  Changeset for adding a new contact to the contact list
  """
  @spec add_contact_changeset(contact_list :: Changeset.t() | t(), attrs :: map()) ::
          Changeset.t()
  def add_contact_changeset(contact_list, attrs) do
    contact_list
    |> cast(attrs, [:contact_user_id])
    |> validate_required([:contact_user_id], message: "user contact is required")
    |> validate_new_contact_not_existing()
  end

  defp validate_new_contact_not_existing(%{valid?: false} = changeset) do
    changeset
  end

  defp validate_new_contact_not_existing(
         %{changes: %{contact_user_id: user_id}, data: data} = changeset
       ) do
    if user_id in data.list, do: add_user_in_contact_error(changeset), else: changeset
  end

  defp add_user_in_contact_error(changeset) do
    add_error(changeset, :contact_user_id, "user already in your contact")
  end
end
