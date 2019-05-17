defmodule MicosUi.Samples.Sample do
  use Ecto.Schema
  import Ecto.Changeset

  alias MicosUi.Samples.Plot

  schema "samples" do
    field :finished_at, :utc_datetime_usec
    field :started_at, :utc_datetime_usec
    field :height1, :float
    field :height2, :float
    field :height3, :float
    field :n2o_slope, :float
    field :n2o_r2, :float
    field :co2_slope, :float
    field :co2_r2, :float
    field :ch4_slope, :float
    field :ch4_r2, :float
    field :air_temperature, :float
    field :soil_temperature, :float
    field :moisture, :float
    field :deleted, :boolean
    belongs_to :plot, Plot

    timestamps()
  end

  @doc false
  def changeset(sample, attrs) do
    sample
    |> cast(attrs, [:plot_id, :height1, :height2, :height3,
      :n2o_slope, :n2o_r2, :co2_slope, :co2_r2, :ch4_slope, :ch4_r2,
      :air_temperature, :soil_temperature, :deleted,
      :started_at, :finished_at ])
     |> validate_required([:plot_id, :height1, :height2, :height3])
  end
end
