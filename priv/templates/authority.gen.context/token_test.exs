defmodule <%= inspect context.token.module %>Test do
  use <%= inspect context.data_case %>, async: true
  alias <%= inspect context.token.module %>

  describe "changeset/2" do
    test "is valid" do
      changeset = Token.changeset(%Token{}, %{purpose: :any})

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :token)
      assert Ecto.Changeset.get_change(changeset, :expires_at)
    end

    test "invalid purpose" do
      changeset = Token.changeset(%Token{}, %{purpose: "garbage"})
      assert errors_on(changeset) == %{purpose: ["is invalid"]}
    end
  end
end
