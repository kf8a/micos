defmodule MicosUi.Repo.Migrations.AddMinutesToPoint do
  use Ecto.Migration

  def change do
    alter table(:points) do
      add :minutes, :float
    end
  end
end
