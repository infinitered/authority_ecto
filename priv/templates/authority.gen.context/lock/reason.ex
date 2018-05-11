defmodule <%= inspect context.lock_reason.module %> do
  use Authority.Ecto.Enum, values: [:too_many_attempts]
end
