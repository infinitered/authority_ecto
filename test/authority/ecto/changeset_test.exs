defmodule Authority.Ecto.ChangesetTest do
  use ExUnit.Case, async: true

  import Ecto.Changeset

  alias Authority.Ecto.Changeset
  alias Authority.Ecto.Test.Token
  alias Authority.Ecto.Test.User

  doctest Authority.Ecto.Changeset, import: true

  @expirations %{
    "72_hours" => {72, :hours}
  }

  @valid_attrs %{
    email: "user@example.com",
    password: "testing123",
    password_confirmation: "testing123"
  }

  defp test_encrypted_password(name, mod) do
    changeset =
      %User{}
      |> change(@valid_attrs)
      |> Changeset.put_encrypted_password(:password, :encrypted_password, name)

    assert hash = get_change(changeset, :encrypted_password)
    assert mod.checkpw(@valid_attrs.password, hash)
  end

  test "put_encrypted_password/3 deletes virtual attributes" do
    changeset =
      %User{}
      |> change(@valid_attrs)
      |> Changeset.put_encrypted_password(:password, :encrypted_password)

    refute get_change(changeset, :password)
    refute get_change(changeset, :password_confirmation)
  end

  test "put_encrypted_password/4 (bcrypt)" do
    test_encrypted_password(:bcrypt, Comeonin.Bcrypt)
  end

  test "put_encrypted_password/4 (argon2)" do
    test_encrypted_password(:argon2, Comeonin.Argon2)
  end

  test "put_encrypted_password/4 (pbkdf2)" do
    test_encrypted_password(:pbkdf2, Comeonin.Pbkdf2)
  end

  test "put_token_expiration/3 sets the expires_at" do
    changeset =
      %Token{}
      |> change(%{purpose: "72_hours"})
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
      |> change(%{purpose: "baloney"})
      |> Changeset.put_token_expiration(:expires_at, :purpose, @expirations)

    refute get_change(changeset, :expires_at)
  end
end
