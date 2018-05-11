defmodule <%= inspect context.token_purpose.module %>Test do
  use ExUnit.Case, async: true
  alias <%= inspect context.token_purpose.module %>

  test "cast/1" do
    assert Purpose.cast(nil) == {:ok, nil}

    assert Purpose.cast(:any) == {:ok, :any}
    assert Purpose.cast("any") == {:ok, :any}

    assert Purpose.cast(:recovery) == {:ok, :recovery}
    assert Purpose.cast("recovery") == {:ok, :recovery}

    assert Purpose.dump("garbage") == :error
  end

  test "dump/1" do
    assert Purpose.dump(nil) == {:ok, nil}

    assert Purpose.dump(:any) == {:ok, "any"}
    assert Purpose.dump("any") == {:ok, "any"}

    assert Purpose.dump(:recovery) == {:ok, "recovery"}
    assert Purpose.dump("recovery") == {:ok, "recovery"}

    assert Purpose.dump("garbage") == :error
  end

  test "load/1" do
    assert Purpose.load(:any) == :error
    assert Purpose.load("any") == {:ok, :any}

    assert Purpose.load(:recovery) == :error
    assert Purpose.load("recovery") == {:ok, :recovery}

    assert Purpose.load("garbage") == :error
  end
end
