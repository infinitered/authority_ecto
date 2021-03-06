defmodule Mix.Authority.Ecto.ContextTest do
  use ExUnit.Case, async: true

  alias Mix.Authority.Ecto.Context

  describe "new/1" do
    setup do: [context: Context.new("Accounts")]

    test "context", %{context: context} do
      assert context.module == AuthorityEcto.Accounts
      assert context.file == "lib/authority_ecto/accounts/accounts.ex"

      assert context.data_case == AuthorityEcto.DataCase
      assert context.test_file =~ "test/authority_ecto/accounts/accounts_test.exs"
    end

    test "migration", %{context: %{migration: migration}} do
      assert migration.module == AuthorityEcto.Repo.Migrations.AuthorityEcto
      assert migration.file =~ ~r"priv/repo/migrations/\d{14}_authority_ecto\.exs"
    end

    test "user", %{context: %{user: user}} do
      assert user.module == AuthorityEcto.Accounts.User
      assert user.table == "users"
      assert user.file == "lib/authority_ecto/accounts/user.ex"
      assert user.test_file == "test/authority_ecto/accounts/user_test.exs"
    end

    test "token", %{context: %{token: token}} do
      assert token.module == AuthorityEcto.Accounts.Token
      assert token.table == "tokens"
      assert token.file == "lib/authority_ecto/accounts/token.ex"
      assert token.test_file == "test/authority_ecto/accounts/token_test.exs"
    end

    test "lock", %{context: %{lock: lock}} do
      assert lock.module == AuthorityEcto.Accounts.Lock
      assert lock.table == "locks"
      assert lock.file == "lib/authority_ecto/accounts/lock.ex"
      assert lock.test_file == "test/authority_ecto/accounts/lock_test.exs"
    end

    test "attempt", %{context: %{attempt: attempt}} do
      assert attempt.module == AuthorityEcto.Accounts.Attempt
      assert attempt.table == "attempts"
      assert attempt.file == "lib/authority_ecto/accounts/attempt.ex"
      assert attempt.test_file == "test/authority_ecto/accounts/attempt_test.exs"
    end
  end
end
