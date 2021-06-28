defmodule MicosUi.Repo.Migrations.AddTemperatureFieldsToPoints do
  use Ecto.Migration

  def change do
    alter table(:points) do
      add :ambient_temperature_c, :float
      add :gas_temperature_c, :float
    end

  end
end
