import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :docker_rel, DockerRel.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "postgres",
  database: "docker_rel_test",
  port: 5432,
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :docker_rel, DockerRelWeb.Endpoint,
  http: [ip: {0, 0, 0, 0}, port: 4002],
  secret_key_base: "PddPIwJdsKcV/m3pK/P4pbBTADkju4Wo7DtRGU/HewA1toCt8L4zVAbCHQX+uo0b",
  server: false

# In test we don't send emails.
config :docker_rel, DockerRel.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters.
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
