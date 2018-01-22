defmodule Authority.Ecto.Template.Authentication do
  @moduledoc false

  defmacro __using__(config) do
    quote location: :keep do
      @hash_algorithms [
        bcrypt: Comeonin.Bcrypt,
        argon2: Comeonin.Argon2,
        pbkdf2: Comeonin.Pbkdf2
      ]

      @config unquote(config)
      @repo @config[:repo]

      @user_schema @config[:user_schema]
      @user_identity_field @config[:user_identity_field] || :email
      @user_password_field @config[:user_password_field] || :encrypted_password
      @user_password_algorithm @config[:user_password_algorithm] || :bcrypt

      unless @user_password_algorithm in Keyword.keys(@hash_algorithms) do
        raise ArgumentError, """
        #{inspect(@user_password_algorithm)} not supported.
        Supported algorithms: #{inspect(Keyword.keys(@hash_algorithms))}
        """
      end

      # Detect if tokenization is being used
      @token_schema @config[:token_schema]
      @token_field @config[:token_field] || :token

      token_example =
        if @token_schema do
          """
          #{inspect(__MODULE__)}.authenticate(%#{inspect(@token_schema)}{#{@token_field}: \"valid\"})
              # => {:ok, %#{inspect(@user_schema)}{}}

              #{inspect(__MODULE__)}.authenticate(%#{inspect(@token_schema)}{#{@token_field}: \"invalid\"})
              # => {:ok, :invalid_token}
          """
        end

      use Authority.Authentication

      @doc """
      Returns a `#{inspect(@user_schema)}` if the credential is valid.

      ## Examples

          #{inspect(__MODULE__)}.authenticate({"valid_#{@user_identity_field}", "password"})
          # => {:ok, %#{inspect(@user_schema)}{}}

          #{inspect(__MODULE__)}.authenticate({"valid_#{@user_identity_field}", "invalid_password"})
          # => {:error, :invalid_password}

          #{inspect(__MODULE__)}.authenticate({"invalid_#{@user_identity_field}", "password"})
          # => {:error, :invalid_#{@user_identity_field}}

          #{token_example}
      """
      @impl Authority.Authentication
      def authenticate(user_or_credential, purpose \\ :any)

      def authenticate(%@user_schema{} = user, _purpose) do
        {:ok, user}
      end

      def authenticate(credential, purpose) do
        super(credential, purpose)
      end

      @doc """
      Identifies an `#{inspect(@user_schema)}` by `#{inspect(@user_identity_field)}`.
      """
      @impl Authority.Authentication
      def identify(identifier) do
        case @repo.get_by(@user_schema, [{@user_identity_field, identifier}]) do
          nil -> {:error, :"invalid_#{@user_identity_field}"}
          user -> {:ok, user}
        end
      end

      @doc false
      @impl Authority.Authentication
      def validate(
            password,
            %@user_schema{@user_password_field => encrypted_password},
            _purpose
          ) do
        case @hash_algorithms[@user_password_algorithm].checkpw(password, encrypted_password) do
          true -> :ok
          false -> {:error, :invalid_password}
        end
      end

      defoverridable Authority.Authentication
    end
  end
end
