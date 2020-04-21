defmodule MicosUiWeb.Router do
  use MicosUiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MicosUiWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/samples", SampleController
  end

  # Other scopes may use custom stacks.
  # scope "/api", MicosUiWeb do
  #   pipe_through :api
  # end
end
