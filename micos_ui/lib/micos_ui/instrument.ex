defmodule MicosUi.Instrument do
  use GenServer

   alias MicosUiWeb.Endpoint

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
    Endpoint.unsubscribe("data")
    Endpoint.unsubscribe("sampling")
    Map.put(state, :sampling, false)
    {:noreply, Map.put(state, :sampling, false)}
  end

  def handle_cast(:start, state) do
    Endpoint.subscribe( "data")
    Endpoint.subscribe( "sampling")
    Endpoint.broadcast_from(self(), "sampling", "start", DateTime.utc_now)
    Process.send_after(self(), :tick, 1_000)
    state = Map.put(state, :sampling, true)
            |> Map.put(:data, [])
    {:noreply, state}
  end

  def handle_info(:tick, %{sampling: true, data: data} = state) do
    new_data = %{datetime: DateTime.utc_now}
    Endpoint.broadcast_from(self(), "data", "new", new_data)
    data = data ++ [new_data]
    Process.send_after(self(), :tick, 1_000)
    {:noreply, Map.put(state, :data, data)}
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end
end
