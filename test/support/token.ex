defmodule Authority.Ecto.Test.Token do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tokens" do
    field(:token, :string)
    field(:purpose, :string)
    field(:expires_at, :utc_datetime)
  end

  def changeset(token, attrs \\ %{}) do
    token
    |> cast(attrs, [:purpose])
  end
end
