defmodule MicosUiWeb.PageController do
  use MicosUiWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
