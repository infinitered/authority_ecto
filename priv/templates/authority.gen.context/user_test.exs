defmodule <%= inspect context.user.module %>Test do
  use <%= inspect context.data_case %>, async: true
  alias <%= inspect context.user.module %>

  @valid_attrs %{
    email: "user@example.com",
    password: "pa$$word",
    password_confirmation: "pa$$word"
  }

  @missing_required %{}
  @invalid_confirmation %{@valid_attrs | password_confirmation: "garbage"}

  describe "changeset" do
    test "is valid" do
      changeset = User.changeset(%User{}, @valid_attrs)
      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :encrypted_password)
    end

    test "requires email and password" do
      changeset = User.changeset(%User{}, @missing_required)

      assert errors_on(changeset) == %{
               email: ["can't be blank"],
               password: ["can't be blank"]
             }
    end

    test "requires confirmation to match" do
      changeset = User.changeset(%User{}, @invalid_confirmation)

      assert errors_on(changeset) == %{
               password_confirmation: ["does not match confirmation"]
             }
    end

    test "requires at least 8 characters" do
      assert errors_for_password("abxz") == ["should be at least 8 character(s)"]
    end

    test "requires a non-blacklisted password" do
      assert errors_for_password("password") == ["is too common"]
    end

    test "requires non-repetitive password" do
      assert errors_for_password("zzzzzzzz") == ["contains more than 3 repeating characters"]
    end

    test "requires non-consecutive password" do
      assert errors_for_password("!abcd1234") == ["contains more than 3 consecutive characters"]
    end
  end

  defp errors_for_password(value) do
    %User{}
    |> User.changeset(%{@valid_attrs | password: value, password_confirmation: value})
    |> errors_on()
    |> Map.fetch!(:password)
  end
end
