defmodule MicosUi.Repo.Migrations.ModifyPoints do
  use Ecto.Migration

  def change do
    alter table(:points) do
      remove :compound
      remove :value
      add :co2, :float
      add :n2o, :float
      add :ch4, :float
      add :datetime, :utc_datetime
    end

  end
end
