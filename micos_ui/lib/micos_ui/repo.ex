defmodule MicosUi.Repo do
  use Ecto.Repo,
    otp_app: :micos_ui,
    adapter: Ecto.Adapters.Postgres
end
