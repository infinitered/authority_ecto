defmodule <%= inspect context.attempt.module %>Test do
  use <%= inspect context.data_case %>, async: true
  alias <%= inspect context.attempt.module %>

  describe "changeset/2" do
    test "is valid" do
      changeset = Attempt.changeset(%Attempt{}, %{})
      assert changeset.valid?
    end
  end
end
