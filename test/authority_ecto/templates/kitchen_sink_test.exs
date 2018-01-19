defmodule Authority.Ecto.KitchenSinkTest do
  use Authority.Ecto.DataCase, async: true

  defmodule Accounts do
    use Authority.Ecto.Template,
      behaviours: [
        Authority.Authentication,
        Authority.Locking,
        Authority.Tokenization
      ],
      config: [
        repo: Authority.Ecto.Test.Repo,
        user_schema: Authority.Ecto.Test.User,
        lock_schema: Authority.Ecto.Test.Lock,
        lock_attempt_schema: Authority.Ecto.Test.Attempt,
        token_schema: Authority.Ecto.Test.Token
      ]
  end

  alias Authority.Ecto.Test.Lock

  setup do
    user = Factory.insert!(:user, email: "valid@email.com")

    {:ok, [user: user]}
  end

  describe ".tokenize/2" do
    test "locks account after too many failed attempts" do
      for _ <- 1..5 do
        Accounts.tokenize({"valid@email.com", "invalid"})
      end

      assert {:error, %Lock{}} = Accounts.tokenize({"valid@email.com", "valid"})
    end
  end
end