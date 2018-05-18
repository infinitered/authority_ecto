defmodule Authority.Ecto.Template.LockingTest do
  use Authority.Ecto.DataCase, async: true

  defmodule Accounts do
    use Authority.Ecto.Template,
      behaviours: [
        Authority.Authentication,
        Authority.Tokenization,
        Authority.Locking
      ],
      config: [
        repo: Authority.Ecto.Test.Repo,
        user_schema: Authority.Ecto.Test.User,
        token_schema: Authority.Ecto.Test.Token,
        lock_schema: Authority.Ecto.Test.Lock,
        lock_attempt_schema: Authority.Ecto.Test.Attempt
      ]
  end

  alias Authority.Ecto.Test.{Lock, Token}

  setup do
    user = Factory.insert!(:user, email: "valid@email.com")

    {:ok, user: user}
  end

  describe ".authenticate/2" do
    test "locks after too many failed attempts" do
      for _ <- 1..5 do
        Accounts.authenticate({"valid@email.com", "invalid"})
      end

      assert {:error, %Lock{reason: :too_many_attempts}} =
               Accounts.authenticate({"valid@email.com", "password"})
    end
  end

  describe ".lock/2" do
    test "locks a user account", %{user: user} do
      assert {:ok, %Lock{}} = Accounts.lock(user, :too_many_attempts)
      assert {:error, %Lock{}} = Accounts.authenticate({"valid@email.com", "password"})
    end
  end

  describe ".unlock/2" do
    test "unlocks a user account", %{user: user} do
      Accounts.lock(user, :too_many_attempts)
      assert {:error, %Lock{}} = Accounts.tokenize({"valid@email.com", "password"})

      Accounts.unlock(user)
      assert {:ok, %Token{}} = Accounts.tokenize({"valid@email.com", "password"})
    end
  end

  describe ".get_lock/1" do
    test "returns the first active lock on the user's account", %{user: user} do
      Accounts.lock(user, :too_many_attempts)
      assert {:ok, %Lock{}} = Accounts.get_lock(user)
    end
  end
end
