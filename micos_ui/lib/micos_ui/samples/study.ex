defmodule MicosUi.Samples.Study do
  use Ecto.Schema
  import Ecto.Changeset

  alias MicosUi.Samples.Plot

  schema "studies" do
    field :name, :string
    has_many :plots, Plot

    timestamps()
  end

  @doc false
  def changeset(study, attrs) do
    study
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
