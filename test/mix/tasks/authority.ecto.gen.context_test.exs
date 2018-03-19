defmodule Authority.Ecto.Gen.ContextTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  alias Mix.Tasks.Authority.Ecto.Gen.Context, as: Generator

  test "generates files for a context" do
    within_project(fn ->
      capture_io(fn -> Generator.run(["Accounts"]) end)

      assert_file "lib/authority_ecto/accounts/accounts.ex", fn file ->
        assert file =~ "defmodule AuthorityEcto.Accounts"
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

      assert [path] = Path.wildcard("priv/repo/migrations/*_authority_ecto.exs")
      assert_file path, fn file ->
        assert file =~ "defmodule AuthorityEcto.Repo.Migrations.AuthorityEcto"
        assert file =~ "create table(:users)"
        assert file =~ "create table(:tokens)"
        assert file =~ "references(:users, on_delete: :nothing)"
      end
    end)
  end

  defp assert_file(file, callback) do
    assert File.regular?(file), "Expected #{file} to exist, but does not"
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
