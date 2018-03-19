if Code.ensure_compiled?(Mix.Authority.Ecto.Context) do
  defmodule Mix.Tasks.Authority.Ecto.Gen.Context do
    use Mix.Task

    alias Mix.Authority.Ecto.Context

    @context_template "priv/templates/authority_ecto.gen.context"

    @doc """
    Generate a new context with Authority.Ecto.Template preconfigured.
    """
    @shortdoc "Generate a context with Authority"
    def run([name]) do
      context = Context.new(name)

      Mix.Phoenix.copy_from(
        [:authority_ecto],
        @context_template,
        [context: context],
        Context.get_files(context)
      )

      Mix.shell.info """

      Remember to update your repository by running migrations:

          $ mix ecto.migrate

      Add a secret to your configuration for storing tokens:

          config #{inspect(context.token_hmac.context_app)}, #{inspect(context.token_hmac.module)},
            secret_key: "some secure value"
      """
    end
  end
end
