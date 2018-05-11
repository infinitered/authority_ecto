defmodule <%= inspect context.lock_reason.module %>Test do
  use ExUnit.Case, async: true
  alias <%= inspect context.lock_reason.module %>

  test "cast/1" do
    assert Reason.cast(nil) == {:ok, nil}
    assert Reason.cast(:too_many_attempts) == {:ok, :too_many_attempts}
    assert Reason.cast("too_many_attempts") == {:ok, :too_many_attempts}
    assert Reason.dump("garbage") == :error
  end

  test "dump/1" do
    assert Reason.dump(nil) == {:ok, nil}
    assert Reason.dump(:too_many_attempts) == {:ok, "too_many_attempts"}
    assert Reason.dump("too_many_attempts") == {:ok, "too_many_attempts"}
    assert Reason.dump("garbage") == :error
  end

  test "load/1" do
    assert Reason.load(:too_many_attempts) == :error
    assert Reason.load("too_many_attempts") == {:ok, :too_many_attempts}
    assert Reason.load("garbage") == :error
  end
end
