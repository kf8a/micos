defmodule MicosUi.Repo.Migrations.RenameMinutesToMinute do
  use Ecto.Migration

  def change do
    rename table("points"), :minutes, to: :minute
  end
end
