defmodule MicosUi.Instrument do
  use GenServer

  alias MicosUiWeb.Endpoint

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{sampling: false, data: [] }, name: MicosUi.Instrument)
  end

  def init(state) do
    {:ok, state}
  end

  def status, do: GenServer.call(__MODULE__, :status)

  def start() do
    GenServer.cast(__MODULE__, :start)
  end

  def stop() do
    GenServer.cast(__MODULE__, :stop)
  end

  def cancel() do
    stop()
  end

  def handle_call(:status, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:stop, state) do
    Endpoint.broadcast_from(self(), "sampling", "stop", DateTime.utc_now)
    unsubscribe()
    Map.put(state, :sampling, false)
    {:noreply, Map.put(state, :sampling, false)}
  end

  def handle_cast(:start, state) do
    subscribe()
    Endpoint.broadcast_from(self(), "sampling", "start", DateTime.utc_now)
    Process.send_after(self(), :tick, 1_000)
    state = Map.put(state, :sampling, true)
            |> Map.put(:data, [])
    {:noreply, state}
  end

  def handle_info(%{licor: result}, %{sampling: true, data: _} = state) do
    Logger.info "licor: #{inspect(result)}"
    state = Map.put(state, :licor, result)
    {:noreply, state}
  end

  def handle_info(%{qcl: result}, %{sampling: true, data: data} = state) do
    Logger.info "qcl: #{inspect(result)}"
    datum = create_datum(state[:qcl], result)
    state = Map.put(state, :data, [datum | data])
    Endpoint.broadcast_from(self(), "data", "new", datum)
    {:noreply, state}
  end

  def handle_info(data, state) do
    Logger.info "unknown #{inspect(data)}"
    {:noreply, state}
  end

  defp subscribe() do
    Endpoint.subscribe("data")
    Endpoint.subscribe("sampling")
    Endpoint.subscribe("licor")
    Endpoint.subscribe("qcl")
  end

  defp unsubscribe() do
    Endpoint.unsubscribe("data")
    Endpoint.unsubscribe("sampling")
    Endpoint.unsubscribe("licor")
    Endpoint.unsubscribe("qcl")
  end

  defp create_datum(qcl, licor) do
    IO.inspect qcl
    IO.inspect licor
    []
  end
end
