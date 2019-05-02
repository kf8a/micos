defmodule MicosUi.Repo.Migrations.AddFluxes do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      add :n2o_slope, :float
      add :n2o_r2, :float
      add :co2_slope, :float
      add :co2_r2, :float
      add :ch4_slope, :float
      add :ch4_r2, :float
    end
  end
end
