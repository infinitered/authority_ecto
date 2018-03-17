defmodule <%= inspect token_schema.module %> do
  use Ecto.Schema
  import Ecto.Changeset
  import Authority.Ecto.Changeset

  @expiration [any: {24, :hours}, recovery: {24, :hours}]

  schema <%= inspect token_schema.table %> do
    field(:token, <%= inspect token_hmac.module %>)
    field(:expires_at, :naive_datetime)
    field(:purpose, <%= inspect token_purpose.module %>)
    belongs_to(:user, <%= inspect user_schema.module %>)
    timestamps()
  end

  @doc false
  def changeset(<%= token_schema.singular %>, attrs) do
    <%= token_schema.singular %>
    |> cast(attrs, [:purpose])
    |> put_token(:token)
    |> put_token_expiration(:expires_at, :purpose, @expiration)
  end
end
