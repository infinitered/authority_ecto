defmodule Authority.Ecto.Password do
  @moduledoc false

  @consecutive_series [
    "abcdefghijklmnopqrstuvwxyz",
    "01234567890"
  ]

  @blacklist "priv/password_blacklist.txt"
             |> File.stream!()
             |> Stream.map(&String.trim/1)
             |> Enum.to_list()

  def blacklist, do: @blacklist

  def repetitive?(value, size) do
    value =~ ~r/(.)\1{#{size - 1}}/
  end

  def consecutive?(value, size) do
    Enum.any?(@consecutive_series, fn series ->
      blacklist = chunk_letters(series, size)

      value
      |> chunk_letters(size)
      |> Enum.any?(&(&1 in blacklist))
    end)
  end

  defp chunk_letters(value, size) do
    value
    |> String.to_charlist()
    |> Enum.chunk_every(size, 1, :discard)
  end
end