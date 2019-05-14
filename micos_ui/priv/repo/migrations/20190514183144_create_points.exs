defmodule MicosUi.Repo.Migrations.CreatePoints do
  use Ecto.Migration

  def change do
    create table(:points) do
      add :sample_id, :integer
      add :compound, :string
      add :value, :float

      timestamps()
    end

  end
end
