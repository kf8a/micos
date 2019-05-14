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


end
