defmodule MicosUi.Repo.Migrations.AddHeights do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      add :height1, :float
      add :height2, :float
      add :height3, :float
    end
  end
end
