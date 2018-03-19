defmodule Authority.Ecto.Test.User do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Authority.Ecto.Changeset

  schema "users" do
    field(:email, :string)
    field(:encrypted_password, :string)

    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email, :password, :password_confirmation])
    |> validate_required([:email, :password])
    |> validate_secure_password(:password)
    |> put_encrypted_password(:password, :encrypted_password)
    |> unique_constraint(:email)
  end
end
