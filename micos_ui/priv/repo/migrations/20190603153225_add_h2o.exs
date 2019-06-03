defmodule MicosUi.Repo.Migrations.AddH2o do
  use Ecto.Migration

  def change do
    alter table(:points) do
      add :h2o_ppm, :float
    end
  end
end
