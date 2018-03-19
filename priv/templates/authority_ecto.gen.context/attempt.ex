defmodule <%= inspect context.attempt.module %> do
  use Ecto.Schema
  import Ecto.Changeset

  schema <%= inspect context.attempt.table %> do
    belongs_to(:user, <%= inspect context.user.module %>)
    timestamps()
  end

  @doc false
  def changeset(<%= context.attempt.singular %>, attrs) do
    <%= context.attempt.singular %>
    |> cast(attrs, [])
  end
end
