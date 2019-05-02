defmodule MicosUi.Sample.Study do
  use Ecto.Schema
  import Ecto.Changeset

  schema "studies" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(study, attrs) do
    study
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
