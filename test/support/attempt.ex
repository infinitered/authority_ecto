defmodule Authority.Ecto.Test.Attempt do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  schema "attempts" do
    belongs_to(:user, Authority.Ecto.Test.User)

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end
end
