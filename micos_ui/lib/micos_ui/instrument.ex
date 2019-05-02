defmodule MicosUi.Instrument do
  use GenServer

  alias MicosUiWeb.Endpoint
  alias MicosUi.Fitter
  alias MicosUi.Samples.Sample

  require Logger

  @debug true

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

  def set_sample(%Sample{} = sample) do
    GenServer.cast(__MODULE__, {:sample, sample})
  end

  def handle_cast({:sample, sample}, state) do
    {:noreply, Map.put(state, :sample, sample)}
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
    now = DateTime.utc_now
    Endpoint.broadcast_from(self(), "sampling", "start", now)
    state = Map.put(state, :sampling, true)
            |> Map.put(:data, [])
            |> Map.put(:sample_start_time, now)

    if @debug do
      Process.send_after(self(), :tick, 1_000)
    end

    {:noreply, state}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "data", payload: licor, topic: "licor"}, %{sampling: true, data: _} = state) do
    state = Map.put(state, :licor, licor)
    {:noreply, state}
  end

  def handle_info(:tick, %{sampling: true, data: data} = state) do
    if @debug do
      Process.send_after(self(), :tick, 1_000)
    end
    datum = %{datetime: DateTime.utc_now(), ch4: :rand.uniform , n2o: :rand.uniform , co2: :rand.uniform}
    data =  [datum | data]
    n2o_flux = Fitter.n2o_flux(data, state[:sample_start_time])
    co2_flux = Fitter.co2_flux(data, state[:sample_start_time])
    ch4_flux = Fitter.ch4_flux(data, state[:sample_start_time])
    state = Map.put(state, :data, data)
            |> Map.put(:n2o_flux, n2o_flux)
            |> Map.put(:co2_flux, co2_flux)
            |> Map.put(:ch4_flux, ch4_flux)

    Endpoint.broadcast_from(self(), "data", "new", datum)
    Endpoint.broadcast_from(self(), "data", "flux", %{n2o_flux: n2o_flux, co2_flux: co2_flux, ch4_flux: ch4_flux})
    {:noreply, state}
  end

  def handle_info(:tick, state) do
    {:noreply, state}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "data", payload: qcl, topic: "qcl"}, %{sampling: true, data: data} = state) do
    datum = %{datetime: DateTime.utc_now(), ch4: :rand.uniform , n2o: :rand.uniform , co2: :rand.uniform}
    data =  [datum | data]
    n2o_flux = Fitter.n2o_flux(data, state[:sample_start_time])
    co2_flux = Fitter.co2_flux(data, state[:sample_start_time])
    ch4_flux = Fitter.ch4_flux(data, state[:sample_start_time])
    state = Map.put(state, :data, data)
            |> Map.put(:n2o_flux, n2o_flux)
            |> Map.put(:co2_flux, co2_flux)
            |> Map.put(:ch4_flux, ch4_flux)

    Endpoint.broadcast_from(self(), "data", "new", datum)
    Endpoint.broadcast_from(self(), "data", "flux", %{n2o_flux: n2o_flux, co2_flux: co2_flux, ch4_flux: ch4_flux})
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


  def combined_datum(%{datetime: datetime, ch4_ppm_dry: ch4_ppm_dry, n2o_ppm_dry: n2o_ppm_dry}, %{co2: co2}) do
    %{datetime: datetime, ch4: ch4_ppm_dry, n2o: n2o_ppm_dry, co2: co2}
  end

end
