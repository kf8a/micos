defmodule MicosUi.Repo.Migrations.CreateSamples do
  use Ecto.Migration

  alias MicosUi.Sample.Plot

  def change do
    create table(:samples) do
      add :plot, references("plots")
      add :started_at, :utc_datetime
      add :finished_at, :utc_datetime

      timestamps()
    end

  end
end
