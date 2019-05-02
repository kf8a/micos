defmodule MicosUi.Sample.Plot do
  use Ecto.Schema
  import Ecto.Changeset

  alias MicosUi.Sample.Study

  schema "plots" do
    field :name, :string
    belongs_to :study, Study

    timestamps()
  end

  @doc false
  def changeset(plot, attrs) do
    plot
    |> cast(attrs, [:name, :study_id])
    |> validate_required([:name, :study_id])
  end
end
