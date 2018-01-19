defmodule Authority.Ecto.PasswordTest do
  use ExUnit.Case, async: true

  alias Authority.Ecto.Password

  test "consecutive values" do
    Enum.each(
      [
        {"ab", 2},
        {"abc", 3},
        {"abcd", 4},
        {"abcde", 5},
        {"abcdef", 6},
        {"abcdefg", 7},
        {"123", 3},
        {"012", 3},
        {"890", 3}
      ],
      fn {value, size} ->
        assert Password.consecutive?(value, size), value
      end
    )
  end

  test "nonconsecutive values" do
    Enum.each(
      [
        {"ab", 3},
        {"abc", 4},
        {"abcd", 5},
        {"abcde", 6},
        {"abcdef", 7},
        {"abcdefg", 8},
        {"123", 4},
        {"z01", 3}
      ],
      fn {value, size} ->
        refute Password.consecutive?(value, size), value
      end
    )
  end

  test "repeating values" do
    Enum.each(
      [
        {"aa", 2},
        {"bbb", 3},
        {"cccc", 4},
        {"ddddd", 5},
        {"111", 3}
      ],
      fn {value, size} ->
        assert Password.repetitive?(value, size), value
      end
    )
  end

  test "nonrepeating values" do
    Enum.each(
      [
        {"aa", 3},
        {"abb", 3},
        {"112", 3},
        {"111", 4}
      ],
      fn {value, size} ->
        refute Password.repetitive?(value, size), value
      end
    )
  end
end
