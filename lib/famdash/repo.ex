defmodule Famdash.Repo do
  use Ecto.Repo,
    otp_app: :famdash,
    adapter: Ecto.Adapters.Postgres
end
