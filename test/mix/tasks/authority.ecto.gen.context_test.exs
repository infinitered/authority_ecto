defmodule Authority.Ecto.Gen.ContextTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  alias Mix.Tasks.Authority.Ecto.Gen.Context, as: Generator

  test "generates files for a context" do
    within_project(fn ->
      capture_io(fn -> Generator.run(["Accounts"]) end)

      assert_file "lib/authority_ecto/accounts/accounts.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts"
        assert file =~ "Authority.Authentication"
        assert file =~ "Authority.Tokenization"
        assert file =~ "Authority.Recovery"
        assert file =~ "Authority.Locking"
        assert file =~ "Authority.Registration"
        assert file =~ "user_schema"
        assert file =~ "token_schema"
        assert file =~ "lock_schema"
        assert file =~ "lock_attempt_schema"
        assert file =~ "recovery_callback"
        assert file =~ "send_forgot_password_email"
      end

      assert_file "lib/authority_ecto/accounts/user.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts.User"
      end

      assert_file "lib/authority_ecto/accounts/token.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts.Token"
      end

      assert_file "lib/authority_ecto/accounts/token/hmac.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts.Token.HMAC"
      end

      assert_file "lib/authority_ecto/accounts/token/purpose.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts.Token.Purpose"
      end

      assert_file "lib/authority_ecto/accounts/lock.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts.Lock"
      end

      assert_file "lib/authority_ecto/accounts/lock/reason.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts.Lock.Reason"
      end

      assert_file "lib/authority_ecto/accounts/attempt.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts.Attempt"
      end

      assert [path] = Path.wildcard("priv/repo/migrations/*_authority_ecto.exs")
      assert_file path, fn file ->
        assert file =~ "defmodule AuthorityEcto.Repo.Migrations.AuthorityEcto"
        assert file =~ "create table(:users)"
        assert file =~ "create table(:tokens)"
        assert file =~ "references(:users, on_delete: :nothing)"
      end
    end)
  end

  test "allows skipping locking" do
    within_project(fn ->
      capture_io(fn -> Generator.run(["Accounts", "--no-locking"]) end)
      refute_file "lib/authority_ecto/accounts/lock.ex"
      refute_file "lib/authority_ecto/accounts/lock/reason.ex"
      refute_file "lib/authority_ecto/accounts/attempt.ex"
      assert_file "lib/authority_ecto/accounts/accounts.ex", fn file ->
        refute file =~ "Authority.Locking"
        refute file =~ "lock_schema"
        refute file =~ "lock_attempt_schema"
      end
    end)
  end

  test "allows skipping registration" do
    within_project(fn ->
      capture_io(fn -> Generator.run(["Accounts", "--no-registration"]) end)
      assert_file "lib/authority_ecto/accounts/accounts.ex", fn file ->
        refute file =~ "Authority.Registration"
      end
    end)
  end

  test "allows skipping tokenization" do
    within_project(fn ->
      capture_io(fn -> Generator.run(["Accounts", "--no-tokenization"]) end)
      refute_file "lib/authority_ecto/accounts/token.ex"
      refute_file "lib/authority_ecto/accounts/token/hmac.ex"
      refute_file "lib/authority_ecto/accounts/token/purpose.ex"
      assert_file "lib/authority_ecto/accounts/accounts.ex", fn file ->
        refute file =~ "Authority.Tokenization"
        refute file =~ "token_schema"
      end
    end)
  end

  test "allows skipping recovery" do
    within_project(fn ->
      capture_io(fn -> Generator.run(["Accounts", "--no-recovery"]) end)
      assert_file "lib/authority_ecto/accounts/accounts.ex", fn file ->
        refute file =~ "Authority.Recovery"
        refute file =~ "recovery_callback"
        refute file =~ "send_forgot_password_email"
      end
    end)
  end

  defp refute_file(file) do
    refute File.regular?(file), "Expected #{file} not to exist"
  end

  defp assert_file(file) do
    assert File.regular?(file), "Expected #{file} to exist"
  end

  defp assert_file(file, callback) do
    assert_file(file)
    callback.(File.read!(file))
  end

  defp within_project(fun) do
    tmp = Path.expand("../../../tmp", __DIR__)
    path = Path.join(tmp, Ecto.UUID.generate())
    cwd = File.cwd!()

    try do
      File.rm_rf!(path)
      File.mkdir_p!(path)
      File.cd!(path, fun)
    after
      File.cd!(cwd)
      File.rm_rf!(path)
    end
  end
end
