defmodule Authority.Ecto.HMACTest do
  use ExUnit.Case, async: true

  alias Authority.Ecto.HMAC

  doctest Authority.Ecto.HMAC, import: true

  defmodule Type do
    use Authority.Ecto.HMAC, secret: "authority"
  end

  describe ".__using__/1" do
    test "raises error if no :secret specified" do
      assert_raise ArgumentError, fn ->
        defmodule Failure do
          use Authority.Ecto.HMAC
        end
      end
    end

    test "produces a functional Ecto.Type" do
      assert Type.type() == :string
      assert Type.cast(123) == {:ok, "123"}
      assert Type.load("hash") == {:ok, "hash"}

      assert Type.dump("value") ==
               {:ok, "4485C853B0D13593389A00B317DA829322F3A3734D63C339E97EAD273441CA45"}
    end
  end

  describe ".hash/2" do
    test "hashes a value with a secret using HMAC" do
      assert HMAC.hash("value", "authority") ==
               "4485C853B0D13593389A00B317DA829322F3A3734D63C339E97EAD273441CA45"
    end
  end

  @configs [
    [secret: "secret"],
    [secret: {:system, "HMAC_SECRET"}],
    [secret: {:app_env, :authority_ecto, :secret}],
    [secret: {:app_env, :authority_ecto, Authority.Ecto.HMAC, :secret}]
  ]

  describe ".secret/1" do
    setup [:create_env]

    test "extracts a secret from configuration" do
      for config <- @configs do
        assert {:ok, "secret"} == HMAC.secret(config),
               "Could not parse config in format #{inspect(config)}"
      end
    end

    test "returns :error if secret could not be parsed" do
      assert :error == HMAC.secret([])
    end
  end

  describe ".secret!/1" do
    setup [:create_env]

    test "extracts a secret from configuration" do
      for config <- @configs do
        assert "secret" == HMAC.secret!(config),
               "Could not parse config in format #{inspect(config)}"
      end
    end

    test "raises ArgumentError if secret could not be parsed" do
      assert_raise ArgumentError, fn ->
        HMAC.secret!([])
      end
    end
  end

  defp create_env(_) do
    System.put_env("HMAC_SECRET", "secret")
    Application.put_env(:authority_ecto, :secret, "secret")
    Application.put_env(:authority_ecto, Authority.Ecto.HMAC, secret: {:system, "HMAC_SECRET"})

    on_exit(fn ->
      System.delete_env("HMAC_SECRET")
      Application.delete_env(:authority_ecto, :secret)
      Application.delete_env(:authority_ecto, Authority.Ecto.HMAC)
    end)
  end
end
