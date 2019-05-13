defmodule MicosUi.Sampler do
  use GenServer

  alias MicosUiWeb.Endpoint
  alias MicosUi.Fitter
  alias MicosUi.Samples
  alias MicosUi.Samples.Sample

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{sampling: false, data: [], sample: %Sample{} }, name: MicosUi.Sampler)
  end

  def init(state) do
    {:ok, state}
  end

  def status, do: GenServer.call(__MODULE__, :status)

  def current_data(), do: GenServer.call(__MODULE__, :data)

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


  def save_sample(%Sample{} = sample, %{ch4_flux: %{slope: ch4_flux, r2: ch4_r2},
                                        co2_flux: %{slope: co2_flux, r2: co2_r2},
                                        n2o_flux: %{slope: n2o_flux, r2: n2o_r2}}) do
    Logger.info "saving sample #{inspect sample}"
    {:ok, _} = Samples.update_sample(sample, %{n2o_slope: n2o_flux, n2o_r2: n2o_r2,
                                               co2_slope: co2_flux, co2_r2: co2_r2,
                                               ch4_slope: ch4_flux, ch4_r2: ch4_r2})
  end

  # If save_sample is called with anything else it will do nothing
  def save_sample(%Sample{} = _, _ ) do
  end

  def compute_fluxes(data, pid) do
    n2o_flux_task = Task.async(fn() -> Fitter.n2o_flux(data) end)
    co2_flux_task = Task.async(fn() -> Fitter.co2_flux(data) end)
    ch4_flux_task = Task.async(fn() -> Fitter.ch4_flux(data) end)

    n2o_flux = Task.await(n2o_flux_task)
    co2_flux = Task.await(co2_flux_task)
    ch4_flux = Task.await(ch4_flux_task)
    Process.send(pid, %{n2o_flux: n2o_flux, co2_flux: co2_flux, ch4_flux: ch4_flux}, [])
  end

  def handle_cast({:sample, sample}, state) do
    {:noreply, Map.put(state, :sample, sample)}
  end

  def handle_cast(:stop, state) do
    unsubscribe()

    save_sample(state[:sample], state)

    state = state
            |> Map.put(:sampling, false)
            |> Map.put(:sample, %Sample{})
    {:noreply, state}
  end

  def handle_cast(:start, state) do
    subscribe()
    now = DateTime.utc_now
    {:ok, sample} = Samples.update_sample(state[:sample], %{started_at: now})

    state = state
            |> Map.put(:sampling, true)
            |> Map.put(:data, [])
            |> Map.put(:sample_start_time, now)
            |> Map.put(:sample, sample)
            |> Map.put(:n2o_flux, %{})
            |> Map.put(:co2_flux, %{})
            |> Map.put(:ch4_flux, %{})

    {:noreply, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:data, _from, state) do
    {:reply, state[:data], state}
  end

  def prep_datum(%Instrument{} = datum, start_time) do
    Map.put(datum, :minute, DateTime.diff(datum.datetime, start_time, :second)/60)
  end

  def handle_info(%Instrument{} = datum, %{sampling: true} = state) do
    # We are sampling and collecting data

    # compute the current fluxes
    start_time = state[:sample].started_at
    data =  [prep_datum(datum, start_time) | state[:data]]

    Task.start(__MODULE__, :compute_fluxes, [data, self()])

    state = state
            |> Map.put(:data, data)

    # emit event to frontend
    Endpoint.broadcast_from(self(), "data", "new", datum)

    {:noreply, state}
  end

  def handle_info(%{n2o_flux: n2o_flux, co2_flux: co2_flux, ch4_flux: ch4_flux}, state) do

    state = state
            |> Map.put(:n2o_flux, n2o_flux)
            |> Map.put(:co2_flux, co2_flux)
            |> Map.put(:ch4_flux, ch4_flux)

    Endpoint.broadcast_from(self(), "data", "flux", %{n2o_flux: n2o_flux, co2_flux: co2_flux, ch4_flux: ch4_flux})
    {:noreply, state}
  end

  def handle_info(%Instrument{} = datum, %{sampling: false} = state) do
    Endpoint.broadcast_from(self(), "data", "new", datum)
    {:noreply, state}
  end

  def handle_info(data, state) do
    Logger.warn "unknown #{inspect(data)}"
    {:noreply, state}
  end

  defp subscribe() do
    Instrument.register(self())
    Endpoint.subscribe("data")
  end

  defp unsubscribe() do
    Instrument.unregister(self())
    Endpoint.unsubscribe("data")
  end
end
