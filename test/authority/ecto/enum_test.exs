defmodule Authority.Ecto.EnumTest do
  use ExUnit.Case, async: true

  doctest Authority.Ecto.Enum

  defmodule Type do
    use Authority.Ecto.Enum, values: [:any, :recovery]
  end

  test "cast/1" do
    assert Type.cast(nil) == {:ok, nil}

    assert Type.cast(:any) == {:ok, :any}
    assert Type.cast("any") == {:ok, :any}

    assert Type.cast(:recovery) == {:ok, :recovery}
    assert Type.cast("recovery") == {:ok, :recovery}

    assert Type.dump("garbage") == :error
  end

  test "dump/1" do
    assert Type.dump(nil) == {:ok, nil}

    assert Type.dump(:any) == {:ok, "any"}
    assert Type.dump("any") == {:ok, "any"}

    assert Type.dump(:recovery) == {:ok, "recovery"}
    assert Type.dump("recovery") == {:ok, "recovery"}

    assert Type.dump("garbage") == :error
  end

  test "load/1" do
    assert Type.load(:any) == :error
    assert Type.load("any") == {:ok, :any}

    assert Type.load(:recovery) == :error
    assert Type.load("recovery") == {:ok, :recovery}

    assert Type.load("garbage") == :error
  end
end
