defmodule <%= inspect context.module %> do
  use Authority.Ecto.Template,
    behaviours: [
      Authority.Authentication,
      Authority.Tokenization,
      Authority.Recovery,
      Authority.Registration,
      Authority.Locking
    ],
    config: [
      repo: <%= inspect context.user.repo %>,
      user_schema: <%= inspect context.user.module %>,
      token_schema: <%= inspect context.token.module %>,
      lock_schema: <%= inspect context.lock.module %>,
      lock_schema_attempt: <%= inspect context.attempt.module %>,
      recovery_callback: {__MODULE__, :send_forgot_password_email}
    ]

  @doc """
  Send a password recovery email to the user.
  """
  def send_forgot_password_email(email, token) do
    IO.warn("Recovering '#{email}' with token '#{token.token}'.")
  end
end
