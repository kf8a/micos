defmodule MicosUi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      MicosUi.Repo,
      {Phoenix.PubSub, [name: MicosUi.PubSub, adapter: Phoenix.PubSub.PG2]},
      MicosUiWeb.Endpoint,
      {Instrument.Reader, Application.get_env(:instrument, :debug)},
      MicosUi.InstrumentMonitor,
      # Start Sampler
      {MicosUi.Sampler, Instrument.Producer},
      MicosUi.Uploader,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MicosUi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MicosUiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
