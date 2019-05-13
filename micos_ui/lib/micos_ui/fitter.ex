defmodule MicosUi.Fitter do

  def n2o_flux(data) do
    {x, y} = data
             |> Enum.map(fn x -> {x.minute, x.n2o} end )
             |> Enum.unzip
    flux(x, y)
  end

  def co2_flux(data) do
    {x, y} = data
             |> Enum.map(fn x -> {x.minute, x.co2} end )
             |> Enum.unzip
    flux(x, y)
  end

  def ch4_flux(data) do
    {x, y} = data
             |> Enum.map(fn x -> {x.minute, x.ch4} end )
             |> Enum.unzip
    flux(x, y)
  end

  def flux(minutes,y) do
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
