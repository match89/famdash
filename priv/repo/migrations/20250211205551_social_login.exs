defmodule Famdash.Repo.Migrations.SocialLogin do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :provider, :string, null: false
      add :uid, :string, null: false
      remove :hashed_password
      remove :confirmed_at
    end
  end
end
