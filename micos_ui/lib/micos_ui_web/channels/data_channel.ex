defmodule MicosUiWeb.DataChannel do
  use Phoenix.Channel
  def join("data:update", _msg, socket) do
    {:ok, socket}
  end
end
