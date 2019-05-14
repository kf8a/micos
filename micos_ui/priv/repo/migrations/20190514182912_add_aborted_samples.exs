defmodule MicosUi.Repo.Migrations.AddAbortedSamples do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      add :deleted, :boolean
    end
  end
end
