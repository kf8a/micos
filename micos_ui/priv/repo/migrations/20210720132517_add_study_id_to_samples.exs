defmodule MicosUi.Repo.Migrations.AddStudyIdToSamples do
  use Ecto.Migration

  def change do
    alter table(:samples) do
      add :study_id, :integer
    end

  end
end
