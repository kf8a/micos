defmodule MicosUi.Repo.Migrations.CreateStudies do
  use Ecto.Migration

  def change do
    create table(:studies) do
      add :name, :string

      timestamps()
    end

  end
end
