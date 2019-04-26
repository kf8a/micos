defmodule MicosUi.Qcl do

  use GenServer

  alias MicosUiWeb.Endpoint
  alias Qcl.Reader

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_status) do
    Endpoint.subscribe("qcl")
    {:ok, _ } = Reader.start_link([])
    Reader.register(self())
    {:ok, []}
  end

  def handle_info(result, state) do
    Endpoint.broadcast_from(self(), "qcl", "data", %{qcl: result})
    {:noreply, state}
  end
end
