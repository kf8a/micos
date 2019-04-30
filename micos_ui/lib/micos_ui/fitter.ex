defmodule MicosUi.Fitter do

  def n2o_flux(data, sample_start_time) do
    {x, y} = data
             |> Enum.map(fn x -> {DateTime.diff(x.datetime, sample_start_time, :second), x.n2o} end )
             |> Enum.unzip
    flux(x, y)
  end

  def co2_flux(data, sample_start_time) do
    {x, y} = data
             |> Enum.map(fn x -> {DateTime.diff(x.datetime, sample_start_time, :second), x.co2} end )
             |> Enum.unzip
    flux(x, y)
  end

  def ch4_flux(data, sample_start_time) do
    {x, y} = data
             |> Enum.map(fn x -> {DateTime.diff(x.datetime, sample_start_time, :second), x.ch4} end )
             |> Enum.unzip
    flux(x, y)
  end

  def flux(x,y) do
    minutes = Enum.map(x, fn(z) -> z/60 end)
    if length(minutes) > 2 do
      {intercept, slope} = Numerix.LinearRegression.fit(minutes,y)
      predicted = Enum.map(minutes, fn(z) -> Numerix.LinearRegression.predict(z, minutes, y) end)
      r_square = Numerix.LinearRegression.r_squared(predicted, y)
      %{intercept: intercept, slope: slope, r2: r_square}
    else
      {:error}
    end
  end

end
