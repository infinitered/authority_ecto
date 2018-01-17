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

  @doc """
  Hashes the value stored in the `source` field, and puts the resulting
  hash in the `destination` field. The `source` field will be removed
  from the changeset.

  By default, the password will be hashed using `Comeonin.Bcrypt`. See
  `put_encrypted_password/4` to use a different algorithm. Valid options
  are `:bcrypt`, `:argon2`, or `:pbkdf2`.

  ## Examples

      iex> put_encrypted_password(changeset, :password, :encrypted_password)
      %Ecto.Changeset{}

      iex> put_encrypted_password(changeset, :password, :encrypted_password, :argon2)
      %Ecto.Changeset{}

  """
  def put_encrypted_password(changeset, source, destination, algorithm \\ :bcrypt) do
    password = get_change(changeset, source)
    confirmation = String.to_existing_atom(Atom.to_string(source) <> "_confirmation")

    if password do
      changeset
      |> put_change(destination, hash_password(algorithm, password))
      |> delete_change(source)
      |> delete_change(confirmation)
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

  Enum.each(
    [
      bcrypt: Comeonin.Bcrypt,
      argon2: Comeonin.Argon2,
      pbkdf2: Comeonin.Pbkdf2
    ],
    fn {name, mod} ->
      if Code.ensure_compiled?(mod) do
        defp hash_password(unquote(name), value) do
          unquote(mod).hashpwsalt(value)
        end
      end
    end
  )

  defp hash_password(name, _value) do
    raise "Invalid algorithm: #{name}. Did you forget to install #{name}_elixir?"
  end
end
