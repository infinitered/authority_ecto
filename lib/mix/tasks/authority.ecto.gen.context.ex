if Code.ensure_compiled?(Mix.Phoenix) do
  defmodule Mix.Tasks.Authority.Ecto.Gen.Context do
    use Mix.Task

    alias Mix.Phoenix.Context
    alias Mix.Phoenix.Schema

    @context_template "priv/templates/authority_ecto.gen.context"

    @doc """
    Run a command
    """
    @shortdoc "Run a command"
    def run([context_name]) do
      user_schema = build_schema(context_name, :User, :users)
      token_schema = build_schema(context_name, :Token, :tokens)
      lock_schema = build_schema(context_name, :Lock, :locks)
      attempt_schema = build_schema(context_name, :Attempt, :attempts)

      context = Context.new(context_name, user_schema, [])

      token_hmac = build_submodule(token_schema, :HMAC, "hmac.ex")
      token_purpose = build_submodule(token_schema, :Purpose, "purpose.ex")
      lock_reason = build_submodule(lock_schema, :Reason, "reason.ex")

      migration = build_migration(user_schema)

      binding = [
        migration: migration,
        context: context,
        user_schema: user_schema,
        token_schema: token_schema,
        token_hmac: token_hmac,
        token_purpose: token_purpose,
        lock_schema: lock_schema,
        lock_reason: lock_reason,
        attempt_schema: attempt_schema
      ]

      files = [
        {:eex, "migration.exs", migration.file},
        {:eex, "context.ex", context.file},
        {:eex, "user.ex", user_schema.file},
        {:eex, "token.ex", token_schema.file},
        {:eex, "token/hmac.ex", token_hmac.file},
        {:eex, "token/purpose.ex", token_purpose.file},
        {:eex, "lock.ex", lock_schema.file},
        {:eex, "lock/reason.ex", lock_reason.file},
        {:eex, "attempt.ex", attempt_schema.file}
      ]

      Mix.Phoenix.copy_from([:authority_ecto], @context_template, binding, files)

      Mix.shell.info """

      Remember to update your repository by running migrations:

          $ mix ecto.migrate

      Add a secret to your configuration for storing tokens:

          config #{inspect(token_hmac.otp_app)}, #{inspect(token_hmac.module)},
            secret_key: "some secure value"
      """
    end

    defp build_schema(context_name, schema_name, table_name) do
      context_name
      |> Module.concat(schema_name)
      |> Schema.new(table_name, [], [])
    end

    defp build_submodule(schema, module, file) do
      dirname = Path.basename(schema.file, ".ex")

      %{
        module: Module.concat(schema.module, module),
        file: Path.expand("../#{dirname}/#{file}", schema.file),
        otp_app: Mix.Phoenix.otp_app()
      }
    end

    defp build_migration(schema) do
      file = "priv/repo/migrations/#{timestamp()}_authority_ecto.exs"

      module =
        schema.repo
        |> Module.concat(:Migrations)
        |> Module.concat(:AuthorityEcto)

      %{file: file, module: module}
    end

    defp timestamp do
      {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
      "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
    end

    defp pad(i) when i < 10, do: <<?0, ?0 + i>>
    defp pad(i), do: to_string(i)
  end
end
