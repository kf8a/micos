defmodule MicosUiWeb.DataView do
  use Phoenix.LiveView

  alias MicosUiWeb.Endpoint

  def render(assigns) do
    MicosUiWeb.PageView.render("data_view.html", assigns)
  end

  def mount(_session, socket) do
    status = MicosUi.Instrument.status()
    IO.inspect status
    data = status[:data]
    Endpoint.subscribe("data")
    {:ok, assign(socket, datetime: DateTime.utc_now, data: data, sampling: status[:sampling])}
  end

  def handle_event("sample", _value, socket) do
    MicosUi.Instrument.start()
    status = MicosUi.Instrument.status()
    IO.inspect status
    data = status[:data]
    {:noreply, assign(socket, datetime: DateTime.utc_now, data: data, sampling: status[:sampling]) }
  end

  def handle_event("stop", _value, socket) do
    MicosUi.Instrument.stop()
    IO.inspect MicosUi.Instrument.status()
    {:noreply, assign(socket, datetime: DateTime.utc_now, sampling: false) }
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "new", payload: payload, topic: "data"} = _event, %Phoenix.LiveView.Socket{assigns: assigns} = socket) do
    data = assigns[:data] ++ [payload]
    IO.inspect data
    {:noreply, assign(socket, datetime: DateTime.utc_now, data: data)}
  end

end
