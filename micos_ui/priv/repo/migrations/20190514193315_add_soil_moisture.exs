defmodule MicosUi.Repo.Migrations.AddSoilMoisture do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      add :moisture, :float
    end
  end
end
