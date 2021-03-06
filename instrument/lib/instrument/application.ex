defmodule Instrument.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      {Licor.Reader, Application.get_env(:instrument, :licor_port_serial_number)},
      Qcl.Reader,
      { Instrument.Reader, Application.get_env(:instrument, :debug)}

      # Starts a worker by calling: Instrument.Worker.start_link(arg)
      # {Instrument.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Instrument.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
