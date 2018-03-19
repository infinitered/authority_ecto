defmodule <%= inspect lock_schema.module %> do
  use Ecto.Schema
  import Ecto.Changeset

  schema <%= inspect lock_schema.table %> do
    field(:expires_at, :naive_datetime)
    field(:reason, <%= inspect lock_reason.module %>)
    belongs_to(:user, <%= inspect user_schema.module %>)
    timestamps()
  end

  @doc false
  def changeset(<%= lock_schema.singular %>, attrs) do
    <%= lock_schema.singular %>
    |> cast(attrs, [:reason, :expires_at])
  end
end
