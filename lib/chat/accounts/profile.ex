defmodule Chat.Accounts.Profile do
  @moduledoc """
  Schema for working with the profiles table
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t() | nil,
          user_id: String.t() | nil,
          last_name: String.t() | nil,
          first_name: String.t() | nil,
          phone_number: String.t() | nil,
          profile_image: String.t() | nil,
          updated_at: NaiveDateTime.t() | nil,
          inserted_at: NaiveDateTime.t() | nil
        }

  @fields [:first_name, :last_name, :phone_number, :user_id]

  @foreign_key_type :binary_id
  @primary_key {:id, :binary_id, autogenerate: true}
  schema "profiles" do
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :profile_image, :string
    belongs_to :user, Chat.Accounts.User

    timestamps()
  end

  @doc """
  Changeset for creating a new profile
  """
  @spec creation_changeset(profile :: Changeset.t() | t(), attrs :: map()) :: Changeset.t()
  def creation_changeset(profile, attrs) do
    profile
    |> cast(attrs, @fields)
    |> validate_required(@fields)
    |> remove_white_space(:last_name)
    |> remove_white_space(:first_name)
    |> remove_white_space(:phone_number)
    |> validate_only_letters(:first_name)
    |> validate_only_letters(:last_name)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:phone_number, message: "phone number already in use")
  end

  defp validate_only_letters(changeset, field) when is_atom(field) do
    validate_format(changeset, field, ~r/^[A-Za-z]+$/u,
      message: "name must only contain letters."
    )
  end

  defp remove_white_space(changeset, field) when is_atom(field) do
    if get_change(changeset, field), do: trim_field(changeset, field), else: changeset
  end

  defp trim_field(changeset, field) do
    value = get_change(changeset, field)
    put_change(changeset, field, String.trim(value))
  end
end
