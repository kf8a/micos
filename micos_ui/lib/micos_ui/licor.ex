defmodule MicosUi.Licor do

  use GenServer

  require Logger

  alias MicosUiWeb.Endpoint

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_status) do
    Endpoint.subscribe("licor")
    {:ok, _ } = Licor.Reader.start_link([])
    Licor.Reader.register(self())
    {:ok, []}
  end

  def handle_info(result, state) do
    Logger.info "licor"
    Logger.info result
    Endpoint.broadcast_from(self(), "licor", "data", {:licor, result})
    {:noreply, state}
  end
end
