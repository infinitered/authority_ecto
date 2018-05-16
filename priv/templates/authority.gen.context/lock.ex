defmodule <%= inspect context.lock.module %> do
  use Ecto.Schema
  import Ecto.Changeset

  defmodule Reason do
    use Authority.Ecto.Enum, values: [:too_many_attempts]
  end

  schema <%= inspect context.lock.table %> do
    field(:expires_at, :utc_datetime)
    field(:reason, Reason)
    belongs_to(:user, <%= inspect context.user.module %>)
    timestamps()
  end

  @doc false
  def changeset(<%= context.lock.singular %>, attrs) do
    <%= context.lock.singular %>
    |> cast(attrs, [:reason, :expires_at])
    |> validate_required(:reason)
  end
end
