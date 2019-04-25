# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :micos_ui, MicosUiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ifNM7JLA0w7uAFg+UdYmwiERth2xDEs1Hdfr4CWBVUhVJh2qNXkl5jAOJGfSQbv/",
  render_errors: [view: MicosUiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MicosUi.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "lRsZg5udV88srXmmGPkIxWHR71ODBLDHYgnjKB7B0/6+WxPbexPFw06Uc++DA+IV"
  ]


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :phoenix,
  template_engines: [leex: Phoenix.LiveView.Engine]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
