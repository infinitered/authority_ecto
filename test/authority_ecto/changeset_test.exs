defmodule Authority.Ecto.ChangesetTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset

  alias Authority.Ecto.Changeset
  alias Authority.Ecto.Test.Token

  @expirations %{
    "72_hours" => {72, :hours}
  }

  test "put_token_expiration/3 sets the expires_at" do
    changeset =
      %Token{}
      |> Token.changeset(%{purpose: "72_hours"})
      |> Changeset.put_token_expiration(:expires_at, :purpose, @expirations)

    actual =
      changeset
      |> get_change(:expires_at)
      |> DateTime.to_unix()

    expected =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.+(259_200)

    assert_in_delta actual, expected, 5
  end

  test "put_token_expiration/3 when no timespec is configured" do
    changeset =
      %Token{}
      |> Token.changeset(%{purpose: "baloney"})
      |> Changeset.put_token_expiration(:expires_at, :purpose, @expirations)

    refute get_change(changeset, :expires_at)
  end
end
