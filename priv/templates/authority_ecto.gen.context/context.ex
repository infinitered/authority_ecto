defmodule <%= inspect context.module %> do
  use Authority.Ecto.Template,
    behaviours: [
      Authority.Authentication,
      Authority.Tokenization,
      Authority.Recovery,
      Authority.Registration
    ],
    config: [
      repo: <%= inspect user_schema.repo %>,
      user_schema: <%= inspect user_schema.module %>,
      token_schema: <%= inspect token_schema.module %>,
      recovery_callback: {__MODULE__, :send_forgot_password_email}
    ]

  @doc """
  Send a password recovery email to the user.
  """
  def send_forgot_password_email(email, token) do
    IO.warn("Recovering '#{email}' with token '#{token.token}'.")
  end
end
