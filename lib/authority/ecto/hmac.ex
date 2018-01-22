defmodule Authority.Ecto.HMAC do
  @moduledoc """
  An `Ecto.Type` to hash secrets (like tokens) using HMAC to reduce the
  chance of leaking, even if your database is compromised.
  If reversible encryption is desired, see the
  [Cloak](https://github.com/danielberkompas/cloak) library instead.

  Relies on `:crypto.hmac/3`, using the hash algorithm `:sha256`.

  ## Configuration

  Define an `HMAC` module in your project:

      defmodule MyApp.HMAC do
        use Authority.Ecto.HMAC, secret: "secret here"
      end

  The `:secret` is **required** and can be specified any of the following ways:

      # A simple string
      secret: "string"

      # An environment variable
      secret: {:system, "VARIABLE_NAME"}

      # An application configuration value
      secret: {:app_env, :my_app, :hmac_secret}

      # An application module configuration value
      secret: {:app_env, :my_app_web, MyAppWeb.Endpoint, :secret}

  If fetching from the `:app_env`, `:system` tuples are still supported.

      config :my_app, hmac_secret: {:system, "HMAC_SECRET"}

  Once your `HMAC` field module is configured, change your secret field's type
  from `:string` to `MyApp.HMAC`.

      schema "tokens" do
        field :token, MyApp.HMAC
      end

  Next, update your changeset function to generate random token strings using
  `Authority.Ecto.Changeset.put_token/2`.

      import Authority.Ecto.Changeset

      def changeset(struct, attrs \\ %{}) do
        struct
        |> cast(attrs, [...])
        |> put_token(:token)
      end

  ## Usage

  The `:token` field will now automatically generate and hash using the
  specified secret.

  This means that **the original token value is only available immediately
  after inserting the record.** You should immediately store the original
  on the client-side. When the token is fetched from the database
  later, only the irreversible hashed value will be returned.

      # The original, raw value is available after insert
      token =
        %Token{}
        |> Token.changeset()
        |> Repo.insert!
      # => %Token{token: "original-value"}

      # Subsequent loads will only return a hashed value
      Repo.get!(Token, token.id)
      # => %Token{token: "4F5410A9D48AD80826A027F98DC7B9E1D20E5C42D3E7F341549954C28B5ABA89"}

  However, if you preserved the original value on the client-side, (such as
  in a session cookie) you can still query using it. Ecto will transparently
  hash the value before using it to query the database.

      Token
      |> where(token: "original-value")
      |> Repo.one()
      # => %Token{token: "4F5410A9D48AD80826A027F98DC7B9E1D20E5C42D3E7F341549954C28B5ABA89"}
  """

  @doc false
  defmacro __using__(config) do
    quote location: :keep do
      alias Authority.Ecto.HMAC

      @behaviour Ecto.Type
      @config unquote(config)
      unless @config[:secret] do
        raise ArgumentError, "You must configure a `:secret` when using `Authority.Ecto.HMAC`"
      end

      @doc false
      def type, do: :string

      @doc false
      def cast(value), do: {:ok, to_string(value)}

      @doc false
      def dump(value), do: {:ok, HMAC.hash(value, HMAC.secret!(@config))}

      @doc false
      def load(value), do: {:ok, value}
    end
  end

  @doc """
  Hashes a given string using the given secret, and returns the value as a
  `Base.encode16/1` string. Relies on `:crypto.hmac/3` with hash algorithm
  `:sha256`.

  ## Examples

      iex> hash("hello world", "authority")
      "0695772E021A6880A6EF0D26C4898E733A1923A7CDBD5150F5B0C38B788A76E8"
  """
  @spec hash(plaintext :: String.t(), secret :: String.t()) :: String.t()
  def hash(plaintext, secret) do
    :sha256
    |> :crypto.hmac(secret, plaintext)
    |> Base.encode16()
  end

  @doc false
  def secret(config) do
    config
    |> Keyword.get(:secret)
    |> get_secret()
  end

  @doc false
  def secret!(config) do
    case secret(config) do
      {:ok, secret} ->
        secret

      :error ->
        raise ArgumentError, ":secret is nil #{inspect(config[:secret])}"
    end
  end

  defp get_secret(nil) do
    :error
  end

  defp get_secret({:app_env, app, key}) do
    app
    |> Application.get_env(key)
    |> get_secret()
  end

  defp get_secret({:app_env, app, module, key}) do
    app
    |> Application.get_env(module)
    |> Keyword.get(key)
    |> get_secret()
  end

  defp get_secret({:system, env}) do
    env
    |> System.get_env()
    |> get_secret()
  end

  defp get_secret(secret) do
    {:ok, secret}
  end
end
