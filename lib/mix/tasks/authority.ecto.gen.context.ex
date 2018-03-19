if Code.ensure_compiled?(Mix.Authority.Ecto.Context) do
  defmodule Mix.Tasks.Authority.Ecto.Gen.Context do
    use Mix.Task

    alias Mix.Authority.Ecto.Context

    @context_template "priv/templates/authority_ecto.gen.context"

    @switches [
      tokenization: :boolean,
      locking: :boolean,
      recovery: :boolean,
      registration: :boolean
    ]

    @default_options [
      authentication: true,
      tokenization: true,
      recovery: true,
      registration: true,
      locking: true
    ]

    @doc """
    Generate a new context with Authority.Ecto.Template preconfigured.
    """
    @shortdoc "Generate a context with Authority"
    def run([name | options]) do
      context = Context.new(name)
      {files, binding} = parse_options(context, options)

      Mix.Phoenix.copy_from(
        [:authority_ecto],
        @context_template,
        binding,
        files
      )

      Mix.shell().info("""

      Remember to update your repository by running migrations:

          $ mix ecto.migrate

      Add a secret to your configuration for storing tokens:

          config #{inspect(context.token_hmac.context_app)}, #{inspect(context.token_hmac.module)},
            secret_key: "some secure value"
      """)
    end

    defp parse_options(context, args) do
      {options, _, _} = OptionParser.parse(args, switches: @switches)
      options = Keyword.merge(@default_options, options)

      %{files: files, behaviours: behaviours, config: config} =
        Enum.reduce(options, %{files: [], behaviours: [], config: []}, fn
          {key, true}, acc ->
            merge(acc, build(context, key))

          _, acc ->
            acc
        end)

      binding = [
        context: context,
        options: options,
        behaviours: behaviours,
        config: config
      ]

      {files, binding}
    end

    defp merge(a, b) do
      %{
        files: a.files ++ b.files,
        behaviours: a.behaviours ++ b.behaviours,
        config: a.config ++ b.config
      }
    end

    defp build(context, :authentication) do
      %{
        files: [
          {:eex, "migration.exs", context.migration.file},
          {:eex, "context.ex", context.file},
          {:eex, "user.ex", context.user.file}
        ],
        behaviours: [Authority.Authentication],
        config: [repo: context.user.repo, user_schema: context.user.module]
      }
    end

    defp build(_context, :registration) do
      %{files: [], behaviours: [Authority.Registration], config: []}
    end

    defp build(context, :recovery) do
      %{
        files: [],
        behaviours: [Authority.Recovery],
        config: [
          recovery_callback: {context.module, :send_forgot_password_email}
        ]
      }
    end

    defp build(context, :tokenization) do
      %{
        files: [
          {:eex, "token.ex", context.token.file},
          {:eex, "token/hmac.ex", context.token_hmac.file},
          {:eex, "token/purpose.ex", context.token_purpose.file}
        ],
        behaviours: [Authority.Tokenization],
        config: [token_schema: context.token.module]
      }
    end

    defp build(context, :locking) do
      %{
        files: [
          {:eex, "lock.ex", context.lock.file},
          {:eex, "lock/reason.ex", context.lock_reason.file},
          {:eex, "attempt.ex", context.attempt.file}
        ],
        behaviours: [Authority.Locking],
        config: [
          lock_schema: context.lock.module,
          lock_schema_attempt: context.attempt.module
        ]
      }
    end
  end
end
