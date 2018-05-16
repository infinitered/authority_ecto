defmodule <%= inspect context.token.module %> do
  use Ecto.Schema
  import Ecto.Changeset
  import Authority.Ecto.Changeset

  @expiration [any: {24, :hours}, recovery: {24, :hours}]

  defmodule HMAC do
    use Authority.Ecto.HMAC,
      secret: {:app_env, <%= inspect context.otp_app %>, __MODULE__, :secret_key}
  end

  defmodule Purpose do
    use Authority.Ecto.Enum, values: [:any, :recovery]
  end

  schema <%= inspect context.token.table %> do
    field(:token, HMAC)
    field(:expires_at, :utc_datetime)
    field(:purpose, Purpose)
    belongs_to(:user, <%= inspect context.user.module %>)
    timestamps()
  end

  @doc false
  def changeset(<%= context.token.singular %>, attrs) do
    <%= context.token.singular %>
    |> cast(attrs, [:purpose])
    |> validate_required(:purpose)
    |> put_token(:token)
    |> put_token_expiration(:expires_at, :purpose, @expiration)
    |> unique_constraint(:token)
  end
end
