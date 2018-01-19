defmodule Authority.Ecto.Test.Token do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Authority.Ecto.Changeset

  defmodule Purpose do
    use Exnumerator, values: [:any, :recovery, :other]
  end

  defmodule HMAC do
    use Authority.Ecto.HMAC, secret: "authority"
  end

  schema "tokens" do
    belongs_to(:user, Authority.Ecto.Test.User)

    field(:token, HMAC)
    field(:expires_at, :utc_datetime)
    field(:purpose, Purpose)

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:expires_at, :purpose])
    |> put_token(:token)
    |> put_token_expiration(:expires_at, :purpose, recovery: {24, :hours}, any: {14, :days})
  end

  def sigil_K(token, _) do
    %__MODULE__{token: token}
  end
end
