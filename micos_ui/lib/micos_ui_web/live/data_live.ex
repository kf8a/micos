defmodule MicosUiWeb.DataLive do
  use MicosUiWeb, :live_view

  alias MicosUiWeb.Endpoint
  alias MicosUi.Samples
  alias MicosUi.Samples.Sample

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    status = MicosUi.Sampler.status()
    plots = Samples.get_plots_for_select(1) # TODO: fix hard coded
    studies = Samples.get_studies_for_select()

    fluxes = round5(flux_to_map(status))

    Endpoint.subscribe("data")
    sample = status[:sample]

    # {:ok, assign(socket, Map.merge(live, fluxes))}
    {:ok,
      assign(socket,
        sampling: status[:sampling],
        changeset: Samples.change_sample(sample),
        plots: plots,
        studies: studies,
        datum: %Instrument{}, duration: "0:0",
        n2o_flux: '', n2o_r2: '', co2_flux: '', co2_r2: '',
        ch4_flux: '', ch4_r2: '',
        fluxes: fluxes
      )}
  end

  def flux_to_map( %{ch4_flux: %{slope: ch4_flux, r2: ch4_r2},
                     co2_flux: %{slope: co2_flux, r2: co2_r2},
                     n2o_flux: %{slope: n2o_flux, r2: n2o_r2}}) do
    %{n2o_flux: n2o_flux, n2o_r2: n2o_r2,
      co2_flux: co2_flux, co2_r2: co2_r2,
      ch4_flux: ch4_flux, ch4_r2: ch4_r2}
  end

  def flux_to_map(_msg) do
    # Logger.warn "flux_to_map called with: #{inspect(msg)}"
    %{n2o_flux: 0, n2o_r2: 0,
      co2_flux: 0, co2_r2: 0,
      ch4_flux: 0, ch4_r2: 0}
    %{}
  end

  def round5(fluxes) do
    Enum.map(fluxes, fn(x) -> round_to_5(x) end)
    |> Enum.into(%{})
  end

  def round_to_5({key, x}) do
    case x do
      nil ->
        {key, x}
      _ ->
        {key, Float.round(x,5)}
    end
  end

  @impl true
  def handle_event("sample", _value, socket) do
    IO.puts "sample"
    MicosUi.Sampler.start()
    MicosUi.Logger.save(%{event: "start", datetime: DateTime.utc_now})
    status = MicosUi.Sampler.status()

    live = %{sampling: status[:sampling]}
    {:noreply, assign(socket, Map.merge(live, round5(flux_to_map(status)))) }
  end

  def handle_event("stop", _value, socket) do
    MicosUi.Logger.save(%{event: "stop", datetime: DateTime.utc_now})
    MicosUi.Sampler.stop()
    status = MicosUi.Sampler.status()
    {:noreply, assign(socket, sampling: status[:sampling],
                              changeset: Samples.change_sample(%Sample{})) }
  end

  def handle_event("abort", _value, socket) do
    MicosUi.Logger.save(%{event: "abort", datetime: DateTime.utc_now})
    MicosUi.Sampler.abort()
    status = MicosUi.Sampler.status()
    {:noreply, assign(socket, sampling: status[:sampling],
                              changeset: Samples.change_sample(%Sample{})) }
  end

  def handle_event("validate",  %{"sample" => params}, socket) do
    status = MicosUi.Sampler.status
    sample = status[:sample]

    plots = MicosUi.Samples.get_plots_for_select(params["study_id"])

    changeset = Sample.changeset(sample, params)

    new_changeset = case Enum.member?(Map.keys(changeset.changes), :study_id) do
      true ->
        {_name, id} = hd(plots)
        Ecto.Changeset.put_change(changeset, :plot_id, id)
      false ->
        changeset
    end

    if new_changeset.valid? do
      {:ok, sample} = Samples.insert_or_update(sample, params)
      MicosUi.Sampler.set_sample(sample)
    end

    {:noreply, assign(socket, sampling: status[:sampling], changeset: changeset, plots: plots) }
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "new", payload: payload, topic: "data"} = _event, %Phoenix.LiveView.Socket{} = socket) do
    status = MicosUi.Sampler.status()

    seconds = abs(rem(trunc(payload.minute * 60), 60)) |> Integer.to_string |> String.pad_leading(2, "0")
    minutes = abs(trunc(payload.minute))
    sign = case status.sampling == :waiting do
      true -> "-"
      _ -> " "
    end
    {:noreply, assign(socket, datum: payload, duration: "#{sign}#{minutes}:#{seconds}")}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "flux", payload: %{ch4_flux: {:error}, co2_flux: {:error}, n2o_flux: {:error}} = payload, topic: "data"}, %Phoenix.LiveView.Socket{} = socket) do
    Logger.info(inspect payload)
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "flux", payload: payload, topic: "data"} = _event, %Phoenix.LiveView.Socket{} = socket) do
    n2o = payload[:n2o_flux]
    co2 = payload[:co2_flux]
    ch4 = payload[:ch4_flux]

    fluxes = %{n2o_flux: n2o[:slope], n2o_r2: n2o[:r2],
              co2_flux: co2[:slope], co2_r2: co2[:r2],
              ch4_flux: ch4[:slope], ch4_r2: ch4[:r2]}

    {:noreply, assign(socket, round5(fluxes)) }
  end

  def handle_info(message, socket) do
    Logger.error "unknown messaage #{inspect message}"
    {:noreply, socket}
  end
end
