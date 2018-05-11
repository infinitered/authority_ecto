defmodule <%= inspect context.token_purpose.module %> do
  use Authority.Ecto.Enum, values: [:any, :recovery]
end
