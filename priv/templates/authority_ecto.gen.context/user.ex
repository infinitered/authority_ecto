defmodule <%= inspect user_schema.module %> do
  use Ecto.Schema
  import Ecto.Changeset
  import Authority.Ecto.Changeset

  schema <%= inspect user_schema.table %> do
    field(:email, :string)
    field(:encrypted_password, :string)
    field(:password, :string, virtual: true)
    timestamps()
  end

  @doc false
  def changeset(<%= user_schema.singular %>, attrs) do
    <%= user_schema.singular %>
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_secure_password(:password)
    |> put_encrypted_password(:password, :encrypted_password)
  end
end
