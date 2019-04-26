defmodule MicosUiWeb.DataView do
  use Phoenix.LiveView

  def render(assigns) do
    MicosUiWeb.PageView.render("data_view.html", assigns)
  end

  def mount(_session, socket) do
    Process.send_after(self(), :tick, 1_000)
    {:ok, assign(socket, datetime: DateTime.utc_now, status: 'waiting' )}
  end

  def handle_info(:tick, socket) do
    Process.send_after(self(), :tick, 1_000)
    {:noreply, assign(socket, datetime: DateTime.utc_now) }
  end

  def handle_event("sample", _value, socket) do
    MicosUi.Instrument.start()
    status = MicosUi.Instrument.status()
    {:noreply, assign(socket, datetime: DateTime.utc_now, status: status) }
  end

end
