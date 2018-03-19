if Code.ensure_compiled?(Mix.Phoenix) do
  defmodule Mix.Authority.Ecto.Context do
    alias Mix.Phoenix.Context
    alias Mix.Phoenix.Schema

    defstruct [
      :module,
      :file,
      :user,
      :token,
      :token_hmac,
      :token_purpose,
      :lock,
      :lock_reason,
      :attempt,
      :migration
    ]

    def new(name) do
      user = build_schema(name, :User, "users")
      token = build_schema(name, :Token, "tokens")
      lock = build_schema(name, :Lock, "locks")
      attempt = build_schema(name, :Attempt, "attempts")

      token_hmac = build_submodule(token, :HMAC, "hmac.ex")
      token_purpose = build_submodule(token, :Purpose, "purpose.ex")
      lock_reason = build_submodule(lock, :Reason, "reason.ex")

      context = Context.new(name, user, [])

      %__MODULE__{
        module: context.module,
        file: context.file,
        migration: build_migration(user),
        user: user,
        token: token,
        lock: lock,
        attempt: attempt,
        token_hmac: token_hmac,
        token_purpose: token_purpose,
        lock_reason: lock_reason
      }
    end

    def get_files(%__MODULE__{} = context) do
      [
        {:eex, "migration.exs", context.migration.file},
        {:eex, "context.ex", context.file},
        {:eex, "user.ex", context.user.file},
        {:eex, "token.ex", context.token.file},
        {:eex, "token/hmac.ex", context.token_hmac.file},
        {:eex, "token/purpose.ex", context.token_purpose.file},
        {:eex, "lock.ex", context.lock.file},
        {:eex, "lock/reason.ex", context.lock_reason.file},
        {:eex, "attempt.ex", context.attempt.file}
      ]
    end

    defp build_schema(context_name, schema_name, table_name) do
      context_name
      |> Module.concat(schema_name)
      |> inspect()
      |> Schema.new(table_name, [], [])
    end

    defp build_submodule(schema, module, file) do
      dirname = Path.basename(schema.file, ".ex")

      %{
        module: Module.concat(schema.module, module),
        file: Path.expand("../#{dirname}/#{file}", schema.file),
        context_app: schema.context_app
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
