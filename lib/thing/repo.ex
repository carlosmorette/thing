defmodule Thing.Repo do
  use Ecto.Repo,
    otp_app: :thing,
    adapter: Ecto.Adapters.Postgres
end
