defmodule Authority.Ecto.Template.AuthenticationTest do
  use Authority.Ecto.DataCase, async: true

  defmodule Accounts do
    use Authority.Ecto.Template,
      behaviours: [Authority.Authentication],
      config: [
        repo: Authority.Ecto.Test.Repo,
        user_schema: Authority.Ecto.Test.User
      ]
  end

  alias Authority.Ecto.Test.User

  setup do
    Factory.insert!(:user, email: "valid@email.com")

    :ok
  end

  describe ".authenticate/2" do
    test "returns error if email is invalid" do
      assert {:error, :invalid_email} = Accounts.authenticate({"invalid@email.com", "password"})
    end

    test "returns error if password is invalid" do
      assert {:error, :invalid_password} = Accounts.authenticate({"valid@email.com", "invalid"})
    end

    test "returns user if email/password are valid" do
      assert {:ok, %User{}} = Accounts.authenticate({"valid@email.com", "password"})
    end

    test "returns user for user" do
      assert {:ok, %User{}} = Accounts.authenticate(%User{})
    end
  end
end
