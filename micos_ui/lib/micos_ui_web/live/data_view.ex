defmodule MicosUiWeb.DataView do
  use Phoenix.LiveView

  alias MicosUiWeb.Endpoint
  alias MicosUi.Samples
  alias MicosUi.Samples.Sample

  require Logger

  def render(assigns) do
    MicosUiWeb.PageView.render("data_view.html", assigns)
  end

  def mount(_session, socket) do
    status = MicosUi.Instrument.status()
    data = status[:data]
    plots = Samples.get_plots_for_select()

    fluxes = round5(flux_to_map(status))

    Endpoint.subscribe("data")

    live = %{data: data, sampling: status[:sampling],
      changeset: Samples.change_sample(%Sample{}), plots: plots,
      datum: '',
      n2o_flux: '', n2o_r2: '', co2_flux: '', co2_r2: '',
      ch4_flux: '', ch4_r2: ''}


    {:ok, assign(socket, Map.merge(live, fluxes))}
  end

  def flux_to_map( %{ch4_flux: %{slope: ch4_flux, r2: ch4_r2},
                     co2_flux: %{slope: co2_flux, r2: co2_r2},
                     n2o_flux: %{slope: n2o_flux, r2: n2o_r2}}) do
    %{n2o_flux: n2o_flux, n2o_r2: n2o_r2,
      co2_flux: co2_flux, co2_r2: co2_r2,
      ch4_flux: ch4_flux, ch4_r2: ch4_r2}
  end

  def flux_to_map(msg) do
    Logger.error "flux_to_map called with: #{inspect(msg)}"
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

  def handle_event("sample", _value, socket) do
    MicosUi.Instrument.start()
    status = MicosUi.Instrument.status()
    data = status[:data]

    live = %{data: data, sampling: status[:sampling]}
    {:noreply, assign(socket, Map.merge(live, round5(flux_to_map(status)))) }
  end

  def handle_event("stop", _value, socket) do
    MicosUi.Instrument.stop()
    status = MicosUi.Instrument.status()
    {:noreply, assign(socket, sampling: status[:sampling]) }
  end

  def handle_event("next", _value, socket) do
    MicosUi.Instrument.stop()
    status = MicosUi.Instrument.status()
    {:noreply, assign(socket, sampling: status[:sampling],
                              changeset: Samples.change_sample(%Sample{})) }
  end

  def handle_event("validate",  %{"sample" => params}, socket) do
    status = MicosUi.Instrument.status
    IO.inspect status[:sample]
    sample = status[:sample]
    changeset = sample
                |> Sample.changeset(params)

    if changeset.valid? do
      {:ok, sample} = Samples.insert_or_update(sample, params)
      MicosUi.Instrument.set_sample(sample)
    end
    IO.inspect status[:sample]

    {:noreply, assign(socket, changeset: changeset) }
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "new", payload: payload, topic: "data"} = _event, %Phoenix.LiveView.Socket{assigns: assigns} = socket) do
    data = assigns[:data] ++ [payload]
    {:noreply, assign(socket, data: data, datum: payload)}
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
    IO.inspect "unkwnon message #{inspect message}"
    Logger.error "unknown messaage #{inspect message}"
    {:noreply, socket}
  end
end
