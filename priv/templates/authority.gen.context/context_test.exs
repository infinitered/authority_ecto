defmodule <%= inspect context.module %>Test do
  use <%= inspect context.data_case %>

  alias <%= inspect context.repo %>
  alias <%= inspect context.module %>
  alias <%= inspect context.user.module %>

  @valid_attrs %{
    email: "user@example.com",
    password: "pa$$word",
    password_confirmation: "pa$$word"
  }

  setup do
    {:ok, user} = Repo.insert(User.changeset(%User{}, @valid_attrs))
    [user: user]
  end
<%= if Authority.Authentication in behaviours do %>
  describe "authentication" do
    test "accepts valid credentials", %{user: user} do
      assert {:ok, ^user} = Accounts.authenticate({user.email, "pa$$word"})
    end

    test "rejects invalid email" do
      assert {:error, :invalid_email} = Accounts.authenticate({"garbage@example.com", "garbage"})
    end

    test "rejects invalid password", %{user: user} do
      assert {:error, :invalid_password} = Accounts.authenticate({user.email, "garbage"})
    end
  end
<% end %><%= if Authority.Registration in behaviours do %>
  describe "registration" do
    @valid_attrs %{@valid_attrs | email: "updated@example.com"}
    @invalid_attrs %{}

    test "retrieve a user", %{user: user} do
      assert {:ok, ^user} = Accounts.get_user(user.id)
    end

    test "create a user" do
      assert {:ok, %User{}} = Accounts.create_user(@valid_attrs)
    end

    test "does not create with invalid attrs" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "updating a user", %{user: user} do
      assert {:ok, updated} = Accounts.update_user(user, @valid_attrs)
      assert updated.id == user.id
      assert updated.email == @valid_attrs.email
    end

    test "does not update with invalid attrs", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
    end
  end
<% end %><%= if Authority.Tokenization in behaviours do %>
  describe "tokenization" do
    alias <%= inspect context.token.module %>

    test "tokenizes a user record", %{user: user} do
      assert {:ok, %Token{}} = Accounts.tokenize(user)
    end

    test "tokenizes valid credentials", %{user: user} do
      assert {:ok, %Token{}} = Accounts.tokenize({user.email, "pa$$word"})
    end

    test "retrieve a token", %{user: user} do
      assert {:ok, token} = Accounts.tokenize(user)
      assert {:ok, found} = Accounts.get_token(token.token)
      assert found.id == token.id
    end

    test "authenticates a valid token", %{user: user} do
      assert {:ok, token} = Accounts.tokenize(user)
      assert {:ok, ^user} = Accounts.authenticate(token)
    end

    test "does not authenticate an invalid token" do
      assert {:error, :invalid_token} = Accounts.authenticate(%Token{token: "garbage"})
    end
  end
<% end %><%= if Authority.Recovery in behaviours do %>
  describe "recovery" do
    test "recovers valid emails", %{user: user} do
      import ExUnit.CaptureIO

      message =
        capture_io(:stderr, fn ->
          assert Accounts.recover(user.email) == :ok
        end)

      assert message =~ "Recovering '#{user.email}'"
    end

    test "does not recover incorrect emails" do
      assert Accounts.recover("garbage@example.com") == {:error, :invalid_email}
    end

    test "allows the user to reset password", %{user: user} do
      assert {:ok, token} = Accounts.tokenize(user, :recovery)
      assert {:ok, %User{}} = Accounts.update_user(token, %{
        password: "new_pa$$word",
        password_confirmation: "new_pa$$word"
      })
    end
  end
<% end %><%= if Authority.Locking in behaviours do %>
  describe "locking" do
    alias <%= inspect context.token.module %>
    alias <%= inspect context.lock.module %>

    test "locks an account after 5 attempts", %{user: user} do
      for _ <- 1..5 do
        assert {:error, :invalid_password} = Accounts.authenticate({user.email, "garbage"})
      end

      assert {:error, %Lock{}} = Accounts.authenticate({user.email, "garbage"})
    end

    test "clears the lock after a recovery", %{user: user} do
      assert {:ok, %Lock{}} = Accounts.lock(user, :too_many_attempts)
      assert {:error, %Lock{}} = Accounts.authenticate({user.email, "pa$$word"})

      assert {:ok, token} = Accounts.tokenize(user, :recovery)
      assert {:ok, user} = Accounts.update_user(token, %{
        password: "new_pa$$word",
        password_confirmation: "new_pa$$word"
      })

      assert {:ok, %User{}} = Accounts.authenticate({user.email, "new_pa$$word"})
    end

    test "can be unlocked manually", %{user: user} do
      assert {:ok, %Lock{}} = Accounts.lock(user, :too_many_attempts)
      assert {:error, %Lock{}} = Accounts.authenticate({user.email, "pa$$word"})

      assert {:ok, %Lock{}} = Accounts.get_lock(user)

      assert :ok = Accounts.unlock(user)
      assert {:ok, %User{}} = Accounts.authenticate({user.email, "pa$$word"})
    end
  end
<% end %>
end
