defmodule <%= inspect migration.module %> do
  use Ecto.Migration

  def change do
    create table(:<%= user_schema.table %>) do
      add(:email, :string)
      add(:encrypted_password, :string)
      timestamps()
    end

    create table(:<%= token_schema.table %>) do
      add(:token, :string)
      add(:purpose, :string)
      add(:expires_at, :naive_datetime)
      add(:user_id, references(:<%= user_schema.table %>, on_delete: :nothing))

      timestamps()
    end

    create(index(:tokens, [:user_id]))
    create(unique_index(:tokens, [:token]))
  end
end
