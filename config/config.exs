# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :thing,
  ecto_repos: [Thing.Repo]

# Configures the endpoint
config :thing, ThingWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ThingWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Thing.PubSub,
  live_view: [signing_salt: "H7t5iD5u"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.12.18",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2016 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :thing, Thing.Scheduler,
  debug_logging: false,
  jobs: [
    {"@daily", fn -> Thing.Repo.delete_all(Thing.Schemas.Message) end},
    {"@daily", fn -> Thing.SubscriberManager.remove_all() end}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
