defmodule <%= inspect token_hmac.module %> do
  use Authority.Ecto.HMAC,
    secret: {:app_env, <%= inspect token_hmac.otp_app %>, __MODULE__, :secret_key}
end
