defmodule MicosUiWeb.DataView do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <div class="">
      <div>
        <%= @datetime%>
      </div>
    </div>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, datetime: DateTime.utc_now )}
  end

end
