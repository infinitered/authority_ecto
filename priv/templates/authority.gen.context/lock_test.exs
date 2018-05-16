defmodule <%= inspect context.lock.module %>Test do
  use <%= inspect context.data_case %>, async: true
  alias <%= inspect context.lock.module %>

  describe "changeset/2" do
    test "is valid" do
      changeset = Lock.changeset(%Lock{}, %{reason: :too_many_attempts})
      assert changeset.valid?
    end

    test "missing reason" do
      changeset = Lock.changeset(%Lock{}, %{})
      assert errors_on(changeset) == %{reason: ["can't be blank"]}
    end

    test "invalid reason" do
      changeset = Lock.changeset(%Lock{}, %{reason: "garbage"})
      assert errors_on(changeset) == %{reason: ["is invalid"]}
    end
  end
end
