defmodule MicosUi.Repo.Migrations.UniquePlotsAndStudies do
  use Ecto.Migration

  def change do
    unique_index("studies", [:name])
    unique_index("plots", [:name, :study])

  end
end
