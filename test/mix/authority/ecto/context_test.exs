defmodule Mix.Authority.Ecto.ContextTest do
  use ExUnit.Case, async: true

  alias Mix.Authority.Ecto.Context

  describe "new/1" do
    setup do: [context: Context.new("Accounts")]

    test "context", %{context: context} do
      assert context.module == AuthorityEcto.Accounts
      assert context.file == "lib/authority_ecto/accounts/accounts.ex"
    end

    test "migration", %{context: %{migration: migration}} do
      assert migration.module == AuthorityEcto.Repo.Migrations.AuthorityEcto
      assert migration.file =~ ~r"priv/repo/migrations/\d{14}_authority_ecto\.exs"
    end

    test "user", %{context: %{user: user}} do
      assert user.module == AuthorityEcto.Accounts.User
      assert user.table == "users"
      assert user.file == "lib/authority_ecto/accounts/user.ex"
    end

    test "token", %{context: %{token: token}} do
      assert token.module == AuthorityEcto.Accounts.Token
      assert token.table == "tokens"
      assert token.file == "lib/authority_ecto/accounts/token.ex"
    end

    test "lock", %{context: %{lock: lock}} do
      assert lock.module == AuthorityEcto.Accounts.Lock
      assert lock.table == "locks"
      assert lock.file == "lib/authority_ecto/accounts/lock.ex"
    end

    test "attempt", %{context: %{attempt: attempt}} do
      assert attempt.module == AuthorityEcto.Accounts.Attempt
      assert attempt.table == "attempts"
      assert attempt.file == "lib/authority_ecto/accounts/attempt.ex"
    end

    test "token_hmac", %{context: %{token_hmac: token_hmac}} do
      assert token_hmac.module == AuthorityEcto.Accounts.Token.HMAC
      assert token_hmac.file == "lib/authority_ecto/accounts/token/hmac.ex"
      assert token_hmac.context_app == :authority_ecto
    end

    test "token_purpose", %{context: %{token_purpose: token_purpose}} do
      assert token_purpose.module == AuthorityEcto.Accounts.Token.Purpose
      assert token_purpose.file == "lib/authority_ecto/accounts/token/purpose.ex"
      assert token_purpose.context_app == :authority_ecto
    end

    test "lock_reason", %{context: %{lock_reason: lock_reason}} do
      assert lock_reason.module == AuthorityEcto.Accounts.Lock.Reason
      assert lock_reason.file == "lib/authority_ecto/accounts/lock/reason.ex"
      assert lock_reason.context_app == :authority_ecto
    end
  end
end
