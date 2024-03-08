defmodule DockerRel.Repo do
  use Ecto.Repo,
    otp_app: :docker_rel,
    adapter: Ecto.Adapters.Postgres
end
