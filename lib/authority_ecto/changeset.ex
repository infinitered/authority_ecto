defmodule Authority.Ecto.Changeset do
  @moduledoc """
  Convenient authentication-related functions for `Ecto.Changeset`s.
  """

  import Ecto.Changeset

  @doc """
  Based on the token's `purpose`, assign an `expires_at` timestamp. The value
  of the `purpose` field should correspond to a key in the `config` list.

  ## Examples

      iex> put_token_expiration(changeset, :expires_at, :purpose, recovery: {24, :hours})
      %Ecto.Changeset{}

  """
  def put_token_expiration(changeset, expiration_field, purpose_field, config)
      when is_list(config) or is_map(config) do
    expires_at =
      config
      |> get_in([get_change(changeset, purpose_field)])
      |> parse_timespec()

    if expires_at do
      put_change(changeset, expiration_field, expires_at)
    else
      changeset
    end
  end

  defp parse_timespec(nil), do: nil

  defp parse_timespec({n, :hours}) do
    parse_timespec({n * 60, :minutes})
  end

  defp parse_timespec({n, :minutes}) do
    parse_timespec({n * 60, :seconds})
  end

  defp parse_timespec({n, :seconds}) do
    DateTime.utc_now()
    |> DateTime.to_unix()
    |> Kernel.+(n)
    |> DateTime.from_unix!()
  end
end
