defmodule Authority.Ecto.Test.User do
  use Ecto.Schema
  import Ecto.Changeset

  @attrs [:email, :password, :password_confirmation]

  schema "users" do
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)
    field(:password_confirmation, :string, virtual: true)
    timestamps()
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @attrs)
  end
end
