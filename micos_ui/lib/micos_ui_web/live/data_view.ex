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

    n2o_flux = status[:n2o_flux]
    co2_flux = status[:co2_flux]
    ch4_flux = status[:ch4_flux]

    Endpoint.subscribe("data")
    {:ok, assign(socket, datetime: DateTime.utc_now, data: data, sampling: status[:sampling],
      n2o_flux: n2o_flux[:slope], n2o_r2: n2o_flux[:r2], co2_flux: co2_flux[:slope], co2_r2: co2_flux[:r2],
      ch4_flux: ch4_flux[:slope], ch4_r2: ch4_flux[:r2],
      changeset: Samples.change_sample(%Sample{}), plots: plots )}
  end

  def handle_event("sample", _value, socket) do
    MicosUi.Instrument.start()
    status = MicosUi.Instrument.status()
    data = status[:data]

    n2o_flux = status[:n2o_flux]
    co2_flux = status[:co2_flux]
    ch4_flux = status[:ch4_flux]

    {:noreply, assign(socket, datetime: DateTime.utc_now, data: data, sampling: status[:sampling],
      n2o_flux: n2o_flux[:slope], n2o_r2: n2o_flux[:r2], co2_flux: co2_flux[:slope], co2_r2: co2_flux[:r2],
      ch4_flux: ch4_flux[:slope], ch4_r2: ch4_flux[:r2])}
  end

  def handle_event("stop", _value, socket) do
    MicosUi.Instrument.stop()
    status = MicosUi.Instrument.status()
    {:noreply, assign(socket, datetime: DateTime.utc_now, sampling: status[:sampling]) }
  end

  def handle_event("next", _value, socket) do
    {:noreply, assign(socket, datetime: DateTime.utc_now, changeset: Samples.change_sample(%Sample{})) }
  end

  def handle_event("validate",  %{"sample" => params}, socket) do

    changeset = %Sample{}
                |> Sample.changeset(params)

    if changeset.valid? do
      {:ok, sample} = Samples.create_sample(changeset.changes)
      MicosUi.Instrument.set_sample(sample)
    end

    {:noreply, assign(socket, changeset: changeset) }
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "new", payload: payload, topic: "data"} = _event, %Phoenix.LiveView.Socket{assigns: assigns} = socket) do
    data = assigns[:data] ++ [payload]
    {:noreply, assign(socket, datetime: DateTime.utc_now, data: data)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "flux", payload: %{ch4_flux: {:error}, co2_flux: {:error}, n2o_flux: {:error}} = payload, topic: "data"}, %Phoenix.LiveView.Socket{} = socket) do
    Logger.info(inspect payload)
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "flux", payload: payload, topic: "data"} = _event, %Phoenix.LiveView.Socket{} = socket) do
    n2o = payload[:n2o_flux]
    co2 = payload[:co2_flux]
    ch4 = payload[:ch4_flux]

    {:noreply, assign(socket,
      datetime: DateTime.utc_now, n2o_flux: n2o[:slope],
      n2o_r2: n2o[:r2], co2_flux: co2[:slope], co2_r2: co2[:r2],
      ch4_flux: ch4[:slope], ch4_r2: ch4[:r2])}
  end

  def handle_info(message, socket) do
    IO.inspect "unkwnon message #{inspect message}"
    Logger.error "unknown messaage #{inspect message}"
    {:noreply, socket}
  end
end
