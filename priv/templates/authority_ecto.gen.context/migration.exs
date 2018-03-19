defmodule <%= inspect migration.module %> do
  use Ecto.Migration

  def change do
    create table(:<%= user_schema.table %>) do
      add(:email, :string, null: false)
      add(:encrypted_password, :string, null: false)
      timestamps()
    end

    create(unique_index(:users, [:email]))

    create table(:<%= token_schema.table %>) do
      add(:token, :string, null: false)
      add(:purpose, :string, null: false)
      add(:expires_at, :naive_datetime, null: false)
      add(:user_id, references(:<%= user_schema.table %>, on_delete: :nothing), null: false)

      timestamps()
    end

    create(index(:tokens, [:user_id]))
    create(unique_index(:tokens, [:token]))
  end
end
