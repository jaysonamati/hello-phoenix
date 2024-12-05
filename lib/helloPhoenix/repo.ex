defmodule HelloPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :helloPhoenix,
    adapter: Ecto.Adapters.Postgres
end
