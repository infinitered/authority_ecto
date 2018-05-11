defmodule Mix.Authority.Ecto.Context do
  defstruct [
    :otp_app,
    :module,
    :repo,
    :file,
    :test_file,
    :user,
    :token,
    :lock,
    :attempt,
    :migration,
    :data_case
  ]

  def new(name) do
    otp_app = Mix.Project.config() |> Keyword.fetch!(:app)
    namespace = predict_namespace(otp_app)

    path = Path.join(["lib", to_string(otp_app), Macro.underscore(name)])
    test_path = Path.join(["test", to_string(otp_app), Macro.underscore(name)])

    module = Module.concat(namespace, name)
    repo = Module.concat(namespace, :Repo)
    data_case = Module.concat(namespace, :DataCase)

    file = Path.join([path, Macro.underscore(name) <> ".ex"])
    test_file = Path.join([test_path, Macro.underscore(name) <> "_test.exs"])
    migration = namespace |> Module.concat(:Repo) |> build_migration()

    paths = {module, path, test_path}
    user = build_schema(paths, {:User, "user", "users"})
    token = build_schema(paths, {:Token, "token", "tokens"})
    lock = build_schema(paths, {:Lock, "lock", "locks"})
    attempt = build_schema(paths, {:Attempt, "attempt", "attempts"})

    %__MODULE__{
      otp_app: otp_app,
      module: module,
      repo: repo,
      file: file,
      test_file: test_file,
      user: user,
      token: token,
      lock: lock,
      attempt: attempt,
      migration: migration,
      data_case: data_case
    }
  end

  defp predict_namespace(otp_app) do
    case Application.get_env(otp_app, :namespace, otp_app) do
      ^otp_app -> otp_app |> to_string() |> Macro.camelize()
      mod -> mod |> inspect()
    end
  end

  defp build_schema({module, path, test_path}, {name, singular, plural}) do
    %{
      file: Path.join(path, singular <> ".ex"),
      test_file: Path.join(test_path, singular <> "_test.exs"),
      module: Module.concat(module, name),
      singular: singular,
      plural: plural,
      table: plural
    }
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
