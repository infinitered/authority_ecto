defmodule <%= inspect context.token_hmac.module %> do
  use Authority.Ecto.HMAC,
    secret: {:app_env, <%= inspect context.otp_app %>, __MODULE__, :secret_key}
end
