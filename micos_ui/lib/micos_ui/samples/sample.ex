defmodule MicosUi.Samples.Sample do
  use Ecto.Schema
  import Ecto.Changeset

  alias MicosUi.Samples.Plot

  schema "samples" do
    field :finished_at, :naive_datetime_usec
    belongs_to :plot, Plot
    field :started_at, :naive_datetime_usec

    timestamps()
  end

  @doc false
  def changeset(sample, attrs) do
    sample
    |> cast(attrs, [:plot_id, :started_at, :finished_at])
    |> validate_required([:plot_id, :started_at, :finished_at])
  end
end
