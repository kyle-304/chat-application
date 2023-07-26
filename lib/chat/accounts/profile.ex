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
    |> validate_phone_number()
    |> trim_field(:first_name)
    |> trim_field(:last_name)
    |> trim_field(:phone_number)
    |> validate_first_name()
    |> validate_last_name()
  end

  defp validate_phone_number(changeset) do
    changeset
    |> validate_required([:phone_number])
    |> validate_length(:phone_number, min: 10)
    |> unique_constraint(:phone_number, message: "phone number already in use")
  end

  defp trim_field(changeset, field) do
    put_change(changeset, field, String.trim(get_change(changeset, field)))
  end

  defp validate_first_name(changeset) do
    changeset
    |> validate_required([:first_name])
    |> validate_format(:first_name, ~r/^[A-Za-z]+$/u,
      message: "First name must only contain letters."
    )
  end

  defp validate_last_name(changeset) do
    changeset
    |> validate_required([:last_name])
    |> validate_format(:last_name, ~r/^[A-Za-z]+$/u,
      message: "Last name must only contain letters."
    )
  end
end
