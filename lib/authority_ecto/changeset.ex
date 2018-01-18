defmodule Authority.Ecto.Changeset do
  @moduledoc """
  Convenient authentication-related functions for `Ecto.Changeset`s.
  """

  import Ecto.Changeset

  @type field :: atom

  @doc """
  Generates a random token value into the given field if it is nil. 

  Best when paired with `Authority.Ecto.HMAC` or
  [Cloak](https://github.com/danielberkompas/cloak) encryption to prevent
  leaking the tokens if the database is compromised.

  ## Examples

  It will set a random value if no value is present:

      iex> changeset = %Token{} |> change() |> put_token(:token)
      ...> is_binary(get_change(changeset, :token))
      true

  If the field already has a value, it will not be changed:

      iex> changeset = %Token{} |> change(token: "existing-value") |> put_token(:token)
      ...> get_field(changeset, :token)
      "existing-value"

      iex> changeset = %Token{token: "existing-value"} |> change() |> put_token(:token)
      ...> get_field(changeset, :token)
      "existing-value"
  """
  @spec put_token(Ecto.Changeset.t(), field) :: Ecto.Changeset.t()
  def put_token(changeset, field) do
    case get_field(changeset, field) do
      nil ->
        put_change(changeset, field, Ecto.UUID.generate())

      _ ->
        changeset
    end
  end

  @doc """
  Based on the token's `purpose`, assign an expiration `DateTime` in the
  given field. 

  The value of the `purpose` field should correspond to a key in the `config`
  list. The following formats are supported:

      {n, :hours}
      {n, :minutes}
      {n, :seconds}

  ## Examples

      iex> changeset = %Token{} |> change(purpose: :recovery)
      ...> changeset = put_token_expiration(changeset, :expires_at, :purpose, recovery: {24, :hours})
      ...> expires_at = get_change(changeset, :expires_at)
      ...> expires_at.__struct__
      DateTime
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
