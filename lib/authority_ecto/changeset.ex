defmodule Authority.Ecto.Changeset do
  @moduledoc """
  Convenient authentication-related functions for `Ecto.Changeset`s.
  """

  import Ecto.Changeset

  alias Authority.Ecto.Password

  @type field :: atom

  @doc """
  Validate that a given password passes some security best practices.
  """
  def validate_secure_password(changeset, field) do
    changeset
    |> validate_length(field, min: 8)
    |> validate_confirmation(field, required: true)
    |> validate_nonrepetitive(field)
    |> validate_nonconsecutive(field)
    |> validate_exclusion(field, Password.blacklist(), message: "is too common")
  end

  def validate_nonrepetitive(changeset, field, opts \\ []) do
    value = get_change(changeset, field)
    max = opts[:max] || 3
    msg = opts[:message] || "contains more than %{max} repeating characters"

    if value && Password.repetitive?(value, max) do
      add_error(changeset, field, msg, validation: :nonrepetitive, max: max)
    else
      changeset
    end
  end

  def validate_nonconsecutive(changeset, field, opts \\ []) do
    value = get_change(changeset, field)
    max = opts[:max] || 3
    msg = opts[:message] || "contains more than %{max} consecutive characters"

    if value && Password.consecutive?(value, max) do
      add_error(changeset, field, msg, validation: :nonconsecutive, max: max)
    else
      changeset
    end
  end

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

  @doc """
  Hashes the value stored in the `source` field, and puts the resulting
  hash in the `destination` field. The `source` field will be removed
  from the changeset.

  By default, the password will be hashed using `Comeonin.Bcrypt`. See
  `put_encrypted_password/4` to use a different algorithm. Valid options
  are `:bcrypt`, `:argon2`, or `:pbkdf2`.

  ## Examples

      iex> changeset = User.changeset(%User{}, %{password: "testing123", password_confirmation: "testing123"})
      ...> changeset = put_encrypted_password(changeset, :password, :encrypted_password)
      ...> Comeonin.Bcrypt.checkpw("testing123", get_change(changeset, :encrypted_password))
      true

      iex> changeset = User.changeset(%User{}, %{password: "testing123", password_confirmation: "testing123"})
      ...> changeset = put_encrypted_password(changeset, :password, :encrypted_password, :argon2)
      ...> Comeonin.Argon2.checkpw("testing123", get_change(changeset, :encrypted_password))
      true

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
