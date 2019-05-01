defmodule MicosUi.Repo.Migrations.CreatePlots do
  use Ecto.Migration

  alias MicosUi.Sample.Study
  def change do
    create table(:plots) do
      add :name, :string
      add :study, references("studies")

      timestamps()
    end

  end
end
