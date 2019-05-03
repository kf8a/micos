defmodule MicosUi.Repo.Migrations.AddTemperatures do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      add :air_temperature, :float
      add :soil_temperature, :float
    end

  end
end
