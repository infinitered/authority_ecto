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

  describe ".put_encrypted_password/3" do
    test "deletes virtual attributes" do
      changeset =
        %User{}
        |> change(@valid_attrs)
        |> Changeset.put_encrypted_password(:password, :encrypted_password)

      refute get_change(changeset, :password)
      refute get_change(changeset, :password_confirmation)
    end
  end

  describe ".put_encrypted_password/4" do
    test "supports :bcrypt algorithm" do
      test_encrypted_password(:bcrypt, Comeonin.Bcrypt)
    end

    test "supports :argon2 algorithm" do
      test_encrypted_password(:argon2, Comeonin.Argon2)
    end

    test "supports :pbkdf2 algorithm" do
      test_encrypted_password(:pbkdf2, Comeonin.Pbkdf2)
    end
  end

  describe ".put_token_expiration/3" do
    test "sets the expires_at field" do
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

    test "changes nothing when no timespec is configured" do
      changeset =
        %Token{}
        |> change(%{purpose: "baloney"})
        |> Changeset.put_token_expiration(:expires_at, :purpose, @expirations)

      refute get_change(changeset, :expires_at)
    end
  end

  describe ".validate_secure_password/2" do
    @tag :regression
    test "does not require password_confirmation if password not changed" do
      changeset =
        %User{}
        |> change(%{email: "test@email.com"})
        |> Changeset.validate_secure_password(:password)

      assert changeset.errors == []
    end
  end

  defp test_encrypted_password(name, mod) do
    changeset =
      %User{}
      |> change(@valid_attrs)
      |> Changeset.put_encrypted_password(:password, :encrypted_password, name)

    assert hash = get_change(changeset, :encrypted_password)
    assert mod.checkpw(@valid_attrs.password, hash)
  end
end
