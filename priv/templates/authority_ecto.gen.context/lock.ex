defmodule <%= inspect context.lock.module %> do
  use Ecto.Schema
  import Ecto.Changeset

  schema <%= inspect context.lock.table %> do
    field(:expires_at, :naive_datetime)
    field(:reason, <%= inspect context.lock_reason.module %>)
    belongs_to(:user, <%= inspect context.user.module %>)
    timestamps()
  end

  @doc false
  def changeset(<%= context.lock.singular %>, attrs) do
    <%= context.lock.singular %>
    |> cast(attrs, [:reason, :expires_at])
  end
end
