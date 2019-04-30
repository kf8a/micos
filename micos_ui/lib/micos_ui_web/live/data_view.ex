defmodule MicosUiWeb.DataView do
  use Phoenix.LiveView

  alias MicosUiWeb.Endpoint

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
      ch4_flux: "", ch4_r2: "" )}
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

  def handle_info(%Phoenix.Socket.Broadcast{event: "new", payload: payload, topic: "data"} = _event, %Phoenix.LiveView.Socket{assigns: assigns} = socket) do
    data = assigns[:data] ++ [payload]
    {:noreply, assign(socket, datetime: DateTime.utc_now, data: data)}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "flux", payload: payload, topic: "data"} = _event, %Phoenix.LiveView.Socket{} = socket) do
    n2o_flux = payload[:n2o_flux]
    co2_flux = payload[:co2_flux]
    ch4_flux = payload[:ch4_flux]

    {:noreply, assign(socket,
      datetime: DateTime.utc_now, n2o_flux: n2o_flux[:slope],
      n2o_r2: n2o_flux[:r2], co2_flux: co2_flux[:slope], co2_r2: co2_flux[:r2],
      ch4_flux: ch4_flux[:slope], ch4_r2: ch4_flux[:r2])}
  end

  def handle_info(message, socket) do
    IO.inspect "unkwnon message #{message}"
    Logger.error "unknown messaage #{message}"
    {:noreply, socket}
  end
end
