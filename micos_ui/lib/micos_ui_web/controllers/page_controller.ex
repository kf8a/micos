defmodule MicosUiWeb.PageController do
  use MicosUiWeb, :controller

  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, MicosUiWeb.DataView, session: %{})
  end
end
