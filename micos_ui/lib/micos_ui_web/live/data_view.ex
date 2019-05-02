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
    Endpoint.subscribe("data")
    {:ok, assign(socket, datetime: DateTime.utc_now, data: data, sampling: status[:sampling], n2o_flux: "",
      n2o_r2: "", co2_flux: "", co2_r2: "",
      ch4_flux: "", ch4_r2: "", plot: status[:plot], changeset: Samples.change_sample(%Sample{}) )}
  end

  def handle_event("sample", _value, socket) do
    MicosUi.Instrument.start()
    status = MicosUi.Instrument.status()
    data = status[:data]
    {:noreply, assign(socket, datetime: DateTime.utc_now, data: data, sampling: status[:sampling])}
  end

  def handle_event("stop", _value, socket) do
    MicosUi.Instrument.stop()
    {:noreply, assign(socket, datetime: DateTime.utc_now, sampling: false) }
  end

  def handle_event("validate", params, socket) do
    changeset = Samples.change_sample(%Sample{})

    # changeset = Map.put(changeset, "sample", "T")
    IO.inspect "change: #{inspect changeset}"

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

  # def handle_info(%Phoenix.Socket.Broadcast{event: "flux", payload: %{ch4_flux: %{intercept: _, r2: ch4_r2, slope: ch4_flux}, co2_flux: %{intercept: _, r2: co2_r2, slope: co2_flux}, n2o_flux: %{intercept: _, r2: n2o_r2, slope: n2o_flux}, topic: "data"}} = _event, %Phoenix.LiveView.Socket{} = socket) do
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
