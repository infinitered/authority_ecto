defmodule <%= inspect context.user.module %> do
  use Ecto.Schema
  import Ecto.Changeset
  import Authority.Ecto.Changeset

  schema <%= inspect context.user.table %> do
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)
    timestamps()
  end

  @doc false
  def changeset(<%= context.user.singular %>, attrs) do
    <%= context.user.singular %>
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_secure_password(:password)
    |> put_encrypted_password(:password, :encrypted_password)
  end
end
