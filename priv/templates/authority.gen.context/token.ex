defmodule <%= inspect context.token.module %> do
  use Ecto.Schema
  import Ecto.Changeset
  import Authority.Ecto.Changeset

  @expiration [any: {24, :hours}, recovery: {24, :hours}]

  schema <%= inspect context.token.table %> do
    field(:token, <%= inspect context.token_hmac.module %>)
    field(:expires_at, :naive_datetime)
    field(:purpose, <%= inspect context.token_purpose.module %>)
    belongs_to(:user, <%= inspect context.user.module %>)
    timestamps()
  end

  @doc false
  def changeset(<%= context.token.singular %>, attrs) do
    <%= context.token.singular %>
    |> cast(attrs, [:purpose])
    |> put_token(:token)
    |> put_token_expiration(:expires_at, :purpose, @expiration)
    |> unique_constraint(:token)
  end
end
