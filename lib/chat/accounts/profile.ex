defmodule Chat.Accounts.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "profiles" do
    field :first_name, :string
    field :last_name, :string
    field :phone_number, :string
    field :profile_image, :string
    belongs_to :user, Chat.Accounts.User
  end

  def profile_changeset(profile, attrs) do
    profile
    |> cast(attrs, [:first_name, :last_name, :phone_number, :profile_image])
    |> validate_required([:first_name, :last_name, :phone_number, :profile_image])
    |> validate_phone_number()
    |> remove_white_space([:first_name, :second_name, :phone_number])
    |> validate_only_letters([:first_name, :second_name])
  end

  defp validate_phone_number(changeset) do
    changeset
    |> validate_length(:phone_number, min: 10)
    |> unique_constraint(:phone_number, message: "phone number already in use")
  end

  defp validate_only_letters(changeset, field) when is_atom(field) do
    changeset
    |> validate_format(field, ~r/^[A-Za-z]+$/u, message: "name must only contain letters.")
  end

  defp remove_white_space(changeset, field) when is_atom(field) do
    value = get_change(changeset, field)

    if is_nil(value) do
      changeset
    else
      String.trim(get_change(changeset, field))
    end
  end
end
