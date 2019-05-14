defmodule MicosUi.MicosUI.Point do
  use Ecto.Schema
  import Ecto.Changeset

  alias MicosUi.Samples.Sample

  schema "points" do
    field :compound, :string
    field :value, :float
    belongs_to :sample, Sample

    timestamps()
  end

  @doc false
  def changeset(point, attrs) do
    point
    |> cast(attrs, [:sample_id, :compound, :value])
    |> validate_required([:sample_id, :compound, :value])
  end
end
