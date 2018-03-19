defmodule <%= inspect migration.module %> do
  use Ecto.Migration

  def change do
    create table(:<%= user_schema.table %>) do
      add(:email, :string, null: false)
      add(:encrypted_password, :string, null: false)
      timestamps()
    end

    create(unique_index(:<%= user_schema.table %>, [:email]))

    create table(:<%= token_schema.table %>) do
      add(:user_id, references(:<%= user_schema.table %>, on_delete: :nothing), null: false)
      add(:token, :string, null: false)
      add(:purpose, :string, null: false)
      add(:expires_at, :naive_datetime, null: false)

      timestamps()
    end

    create(index(:<%= token_schema.table %>, [:user_id]))
    create(unique_index(:<%= token_schema.table %>, [:token]))

    create table(:<%= lock_schema.table %>) do
      add(:user_id, references(:<%= user_schema.table %>, on_delete: :nothing), null: false)
      add(:reason, :string, null: false)
      add(:expires_at, :naive_datetime, null: false)
      timestamps()
    end

    create(index(:<%= lock_schema.table %>, [:user_id]))

    create table(:<%= attempt_schema.table %>) do
      add(:user_id, references(:<%= user_schema.table %>, on_delete: :nothing), null: false)
      timestamps()
    end

    create(index(:<%= attempt_schema.table %>, [:user_id]))
  end
end
