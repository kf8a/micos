defmodule MicosUi.Repo.Migrations.CreateSamples do
  use Ecto.Migration

  alias MicosUi.Sample.Plot

  def change do
    create table(:samples) do
      add :plot_id, references("plots")
      add :started_at, :utc_datetime_usec
      add :finished_at, :utc_datetime_usec

      timestamps()
    end

  end
end
