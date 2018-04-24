defmodule Mix.Tasks.Authority.Gen.Context do
  use Mix.Task

  alias Mix.Authority.Ecto.Context

  @context_template "priv/templates/authority.gen.context"

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
  def run([name | args]) do
    context = Context.new(name)
    {files, behaviours, config} = build_features(context, args)

    binding = [
      context: context,
      config: config,
      behaviours: Enum.sort_by(behaviours, &behaviour_order/1)
    ]

    for {source, target} <- files do
      Mix.Generator.create_file(target, render(source, binding))
    end

    Mix.shell().info("""

    Remember to update your repository by running migrations:

        $ mix ecto.migrate

    Add a secret to your configuration for storing tokens:

        config #{inspect(context.otp_app)}, #{inspect(context.token_hmac.module)},
          secret_key: "some secure value"
    """)
  end

  defp render(source, binding) do
    :authority_ecto
    |> Application.app_dir(Path.join(@context_template, source))
    |> EEx.eval_file(binding)
  end

  defp build_features(context, args) do
    {options, _, _} = OptionParser.parse(args, switches: @switches)

    @default_options
    |> Keyword.merge(options)
    |> Enum.reduce({[], [], []}, &build_feature(&2, context, &1))
  end

  defp build_feature(spec, context, {:authentication, true}) do
    spec
    |> put_file("migration.exs", context.migration.file)
    |> put_file("context.ex", context.file)
    |> put_file("user.ex", context.user.file)
    |> put_behaviour(Authority.Authentication)
    |> put_config(:repo, context.repo)
    |> put_config(:user_schema, context.user.module)
  end

  defp build_feature(spec, _context, {:registration, true}) do
    put_behaviour(spec, Authority.Registration)
  end

  defp build_feature(spec, context, {:recovery, true}) do
    spec
    |> put_behaviour(Authority.Recovery)
    |> put_config(:recovery_callback, {context.module, :send_forgot_password_email})
  end

  defp build_feature(spec, context, {:tokenization, true}) do
    spec
    |> put_file("token.ex", context.token.file)
    |> put_file("token/hmac.ex", context.token_hmac.file)
    |> put_file("token/purpose.ex", context.token_purpose.file)
    |> put_behaviour(Authority.Tokenization)
    |> put_config(:token_schema, context.token.module)
  end

  defp build_feature(spec, context, {:locking, true}) do
    spec
    |> put_file("lock.ex", context.lock.file)
    |> put_file("lock/reason.ex", context.lock_reason.file)
    |> put_file("attempt.ex", context.attempt.file)
    |> put_behaviour(Authority.Locking)
    |> put_config(:lock_schema, context.lock.module)
    |> put_config(:lock_attempt_schema, context.attempt.module)
  end

  defp build_feature(spec, _context, _), do: spec

  defp put_file({files, behaviours, config}, src, dest) do
    {[{src, dest} | files], behaviours, config}
  end

  defp put_behaviour({files, behaviours, config}, behaviour) do
    {files, [behaviour | behaviours], config}
  end

  defp put_config({files, behaviours, config}, key, value) do
    {files, behaviours, [{key, value} | config]}
  end

  defp behaviour_order(Authority.Authentication), do: 0
  defp behaviour_order(Authority.Tokenization), do: 1
  defp behaviour_order(Authority.Recovery), do: 2
  defp behaviour_order(Authority.Registration), do: 3
  defp behaviour_order(Authority.Locking), do: 4
end
