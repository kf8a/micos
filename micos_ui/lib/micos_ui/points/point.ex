defmodule MicosUi.Points.Point do
  use Ecto.Schema
  import Ecto.Changeset

  alias MicosUi.Samples.Sample

  schema "points" do
    field :datetime, :utc_datetime
    field :n2o, :float
    field :co2, :float
    field :ch4, :float
    field :h2o_ppm, :float
    field :ambient_temperature_c, :float
    field :gas_temperature_c, :float
    field :minute, :float
    field :uploaded, :boolean, default: false
    belongs_to :sample, Sample

    timestamps()
  end

  @doc false
  def changeset(point, attrs) do
    point
    |> cast(attrs, [:sample_id, :n2o, :co2, :ch4,
      :ambient_temperature_c, :gas_temperature_c,
      :datetime, :minute])
    |> validate_required([:sample_id, :datetime, :minute])
  end
end
