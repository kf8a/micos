defmodule MicosUi.Points do
  @moduledoc """
  data points context
  """

  import Ecto.Query, warn: false
  alias MicosUi.Repo

  alias MicosUi.Points.Point

  def create_point(attrs \\ %{}) do
    %Point{}
    |> Point.changeset(attrs)
    |> Repo.insert()
  end

  def list_points_to_upload() do
    query = from s in MicosUi.Points.Point,
      where: s.uploaded == false,
      limit: 10_000
    Repo.all(query)
  end

end
