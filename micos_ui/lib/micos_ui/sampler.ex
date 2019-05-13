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

  def handle_info(%Instrument{} = datum, %{sampling: true} = state) do
    # We are sampling and collecting data
    data =  [datum | state[:data]]

    # compute the current fluxes
    start_time = state[:sample].started_at
    n2o_flux = Fitter.n2o_flux(data, start_time)
    co2_flux = Fitter.co2_flux(data, start_time)
    ch4_flux = Fitter.ch4_flux(data, start_time)

    state = state
            |> Map.put(:n2o_flux, n2o_flux)
            |> Map.put(:co2_flux, co2_flux)
            |> Map.put(:ch4_flux, ch4_flux)

    # emit event to frontend
    Endpoint.broadcast_from(self(), "data", "new", datum)
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
