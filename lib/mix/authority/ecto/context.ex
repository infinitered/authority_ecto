defmodule Mix.Authority.Ecto.Context do
  defstruct [
    :otp_app,
    :module,
    :repo,
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
    otp_app = Mix.Project.config() |> Keyword.fetch!(:app)
    namespace = predict_namespace(otp_app)

    path = Path.join(["lib", to_string(otp_app), Macro.underscore(name)])

    module = Module.concat(namespace, name)
    repo = Module.concat(namespace, :Repo)

    file = Path.join([path, Macro.underscore(name) <> ".ex"])
    migration = namespace |> Module.concat(:Repo) |> build_migration()

    user = build_schema({module, path}, {:User, "user", "users"})
    token = build_schema({module, path}, {:Token, "token", "tokens"})
    lock = build_schema({module, path}, {:Lock, "lock", "locks"})
    attempt = build_schema({module, path}, {:Attempt, "attempt", "attempts"})

    token_hmac = build_submodule(token, {:HMAC, "hmac"})
    token_purpose = build_submodule(token, {:Purpose, "purpose"})
    lock_reason = build_submodule(lock, {:Reason, "reason"})

    %__MODULE__{
      otp_app: otp_app,
      module: module,
      repo: repo,
      file: file,
      user: user,
      token: token,
      lock: lock,
      attempt: attempt,
      migration: migration,
      token_hmac: token_hmac,
      token_purpose: token_purpose,
      lock_reason: lock_reason
    }
  end

  defp predict_namespace(otp_app) do
    case Application.get_env(otp_app, :namespace, otp_app) do
      ^otp_app -> otp_app |> to_string() |> Macro.camelize()
      mod -> mod |> inspect()
    end
  end

  defp build_schema({module, path}, {name, singular, plural}) do
    %{
      file: Path.join(path, singular <> ".ex"),
      module: Module.concat(module, name),
      singular: singular,
      plural: plural,
      table: plural
    }
  end

  defp build_submodule(schema, {name, singular}) do
    module = Module.concat(schema.module, name)

    file =
      schema.file
      |> Path.dirname()
      |> Path.join(Path.basename(schema.file, ".ex"))
      |> Path.join(singular <> ".ex")

    %{module: module, file: file}
  end

  defp build_migration(repo) do
    file = "priv/repo/migrations/#{timestamp()}_authority_ecto.exs"

    module =
      repo
      |> Module.concat(:Migrations)
      |> Module.concat(:AuthorityEcto)

    %{module: module, file: file}
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)
end
