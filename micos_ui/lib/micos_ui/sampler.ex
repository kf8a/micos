defmodule MicosUi.Sampler do
  @moduledoc """
  Orchestrates the sampling and calculation. It is subscribed to the instrument producer and accumulates samples.

  This sampler has 3 states. It starts out in :off then moves to :waiting, to :sampling and back to :off

  """
  use GenStage

  alias MicosUiWeb.Endpoint
  alias MicosUi.Fitter
  alias MicosUi.Samples
  alias MicosUi.Samples.Sample

  require Logger

  # sampling: should be one of :off, :waiting, or :sampling
  def start_link(producer) do
    GenStage.start_link(__MODULE__, %{producer: producer, interval: 0, sampling: :off, data: [], sample: %Sample{} }, name: __MODULE__)
  end

  @impl true
  def init(state) do
    producer = state[:producer]
    {:consumer, state, subscribe_to: [{producer, []}]}
  end

  def status, do: GenStage.call(__MODULE__, :status)

  @doc """
  Return the current accumulated data of the module
  """
  def current_data(), do: GenStage.call(__MODULE__, :data)

  @doc """
  return the current flux calculations
  """
  def current_fluxes(), do: GenStage.call(__MODULE__, :fluxes)

  @doc """
  start a new sample. This starts the 2 minute countdown timer and then starts to collect sample values
  """
  def start() do
    GenStage.cast(__MODULE__, :start)
  end

  @doc """
  Stop and save a sample
  """
  def stop() do
    GenStage.cast(__MODULE__, :stop)
  end

  @doc """
  Abort a sample
  """
  def abort() do
    GenStage.cast(__MODULE__, :abort)
  end

  def set_sample(%Sample{} = sample) do
    GenStage.cast(__MODULE__, {:sample, sample})
  end

  def save_sample_flux(%Sample{} = sample, %{ch4_flux: %{slope: ch4_flux, r2: ch4_r2},
                                            co2_flux: %{slope: co2_flux, r2: co2_r2},
                                            n2o_flux: %{slope: n2o_flux, r2: n2o_r2}}) do
    Logger.info "saving sample #{inspect sample}"

    case Samples.update_sample(sample, %{n2o_slope: n2o_flux, n2o_r2: n2o_r2,
                                         co2_slope: co2_flux, co2_r2: co2_r2,
                                         ch4_slope: ch4_flux, ch4_r2: ch4_r2}) do
      {:ok, sample} ->
        sample
      {:error, changeset} ->
        Logger.warn "Failed to save sample with fluxes: #{inspect changeset}"
    end
  end

  # If save_sample is called with anything else it will do nothing
  def save_sample_flux(%Sample{} = _, _ ) do
  end

  def abort_sample(sample) do
    case Samples.update_sample(sample, %{finished_at: DateTime.utc_now()}) do
      {:ok, sample} ->
        sample
      {:error, changeset} ->
        Logger.warn "failed to update sample with finished: #{inspect changeset}"
    end
    case Samples.update_sample(sample, %{deleted: true}) do
      {:ok, sample} ->
        sample
      {:error, changeset} ->
        Logger.warn "failed to update sample with deleted: #{inspect changeset}"
    end
  end

  def compute_fluxes(data, pid) do
    n2o_flux_task = Task.async(fn() -> Fitter.n2o_flux(data) end)
    co2_flux_task = Task.async(fn() -> Fitter.co2_flux(data) end)
    ch4_flux_task = Task.async(fn() -> Fitter.ch4_flux(data) end)

    n2o_flux = Task.await(n2o_flux_task, 25_000)
    co2_flux = Task.await(co2_flux_task, 25_000)
    ch4_flux = Task.await(ch4_flux_task, 25_000)
    Process.send(pid, %{n2o_flux: n2o_flux, co2_flux: co2_flux, ch4_flux: ch4_flux}, [])
  end

  @doc """
  Set the state to sampling
  """
  @impl true
  def handle_cast({:sample, sample}, state) do
    {:noreply, [], Map.put(state, :sample, sample)}
  end

  @impl true
  def handle_cast(:abort, %{sampling: :sampling} = state) do
    Endpoint.unsubscribe("data")
    sample = state[:sample]
    Task.start(fn() -> abort_sample(sample) end)

    state = state
            |> Map.put(:sampling, :off)
            |> Map.put(:sample, %Sample{})
    {:noreply, [], state}
  end

  @impl true
  def handle_cast(:abort, state) do
    {:noreply, [], Map.put(state, :sampling, :off)}
  end

  @impl true
  def handle_cast(:stop, %{sampling: :sampling} = state) do
    Endpoint.unsubscribe("data")

    sample = state[:sample]

    case Samples.update_sample(sample, %{finished_at: DateTime.utc_now()}) do
      {:ok, sample} ->
        sample
      {:error, changeset} ->
        Logger.warn "failed to save sample while stopping #{inspect changeset}"
    end

    # handle the saving in a separate process
    Task.start(fn() ->  save_sample_flux(sample, state) end)

    state = state
            |> Map.put(:sampling, :off)
            |> Map.put(:sample, %Sample{})
    {:noreply, [], state}
  end

  def handle_cast(:stop, state) do
    {:noreply, [], Map.put(state, :sampling, :off)}
  end

  def handle_cast(:start, state) do
    Process.send_after(self(), :sample, 120_000)

    Endpoint.subscribe("data")

    state = state
            |> Map.put(:sampling, :waiting)
            |> Map.put(:sample_start_time, DateTime.utc_now())

    {:noreply, [], state}
  end

  @impl true
  def handle_call(:status, _from, state) do
    {:reply, state, [], state}
  end

  @impl true
  def handle_call(:data, _from, state) do
    {:reply, state[:data], [], state}
  end

  @impl true
  def handle_call(:fluxes, _from, state) do
    data = %{
      co2: state[:co2_flux],
      n2o: state[:n2o_flux],
      ch4: state[:ch4_flux]
    }
    {:reply, data, [], state}
  end

  def prep_datum(%Instrument{} = datum, start_time) do
    Map.put(datum, :minute, DateTime.diff(datum.datetime, start_time, :second)/60)
  end

  @impl true
  def handle_events(events, _from, state) when is_list(events) and length(events) > 0 do
    # when events arrive send them off to ourselves individually
    # TODO: it should handle the new events directly instead of redirecting
    Enum.each(events, fn(event) -> Process.send_after(self(),event, 1) end)
    {:noreply,  [], state}
  end

  @doc """
  start sampling
  """
  @impl true
  def handle_info(:sample, state) do
    now = DateTime.utc_now
    {:ok, sample} = Samples.update_sample(state[:sample], %{started_at: now})

    state = state
            |> Map.put(:sampling, :sampling)
            |> Map.put(:data, [])
            |> Map.put(:sample_start_time, now)
            |> Map.put(:sample, sample)
            |> Map.put(:n2o_flux, %{})
            |> Map.put(:co2_flux, %{})
            |> Map.put(:ch4_flux, %{})

    {:noreply, [], state}
  end

  # We are sampling and collecting data
  def handle_info(%Instrument{} = datum, %{sampling: :sampling} = state) do
    new_datum = prep_datum(datum, state[:sample_start_time])
    data =  [new_datum | state[:data]]

    # every 30 seconds or so
    # compute the current fluxes
    interval = rem(state[:interval] + 1, 10)
    if interval == 0 do
      Task.start(__MODULE__, :compute_fluxes, [data, self()])
    end

    # save data to db
    MicosUi.Points.create_point(Map.put(Map.from_struct(new_datum), :sample_id, state[:sample].id))

    state = state
            |> Map.put(:data, data)
            |> Map.put(:interval, interval)

    # emit event to frontend
    Endpoint.broadcast_from(self(), "data", "new", new_datum)

    {:noreply, [], state}
  end

  # we are listening and waiting to start
  def handle_info(%Instrument{} = datum, %{sampling: :waiting} = state) do
    new_datum = Map.put(datum, :minute, DateTime.diff(DateTime.utc_now(), state[:sample_start_time], :second)/60 - 2 )
    Endpoint.broadcast_from(self(), "data", "new", new_datum)
    {:noreply, [], state}
  end

  def handle_info(%Instrument{} = datum, state) do
    Endpoint.broadcast_from(self(), "data", "new", datum)
    {:noreply, [], state}
  end

  def handle_info(%{n2o_flux: n2o_flux, co2_flux: co2_flux, ch4_flux: ch4_flux}, state) do

    state = state
            |> Map.put(:n2o_flux, n2o_flux)
            |> Map.put(:co2_flux, co2_flux)
            |> Map.put(:ch4_flux, ch4_flux)

    Endpoint.broadcast_from(self(), "data", "flux", %{n2o_flux: n2o_flux, co2_flux: co2_flux, ch4_flux: ch4_flux})
    {:noreply, [], state}
  end

  def handle_info(data, state) do
    Logger.warn "unknown #{inspect(data)}"
    {:noreply, [], state}
  end

end
