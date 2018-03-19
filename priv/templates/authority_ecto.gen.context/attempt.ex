defmodule <%= inspect attempt_schema.module %> do
  use Ecto.Schema
  import Ecto.Changeset

  schema <%= inspect attempt_schema.table %> do
    belongs_to(:user, <%= inspect user_schema.module %>)
    timestamps()
  end

  @doc false
  def changeset(<%= attempt_schema.singular %>, attrs) do
    <%= attempt_schema.singular %>
    |> cast(attrs, [])
  end
end
