defmodule MicosUi.Fitter do

  alias LearnKit.Regression.Linear

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

  def flux(minutes,y) when length(minutes) > 2 do
    predictor = Linear.new(minutes, y)
                |> Linear.fit
    {:ok, r_square} = Linear.score(predictor)
    [intercept, slope] = predictor.coefficients
    %{intercept: intercept, slope: slope, r2: r_square}
  end

  def flux(_minutes,_y) do
    {:error}
  end

  # def flux(minutes,y) do
  #   if length(minutes) > 2 do
  #     {intercept, slope} = Numerix.LinearRegression.fit(minutes,y)
  #     predicted = Enum.map(minutes, fn(z) -> Numerix.LinearRegression.predict(z, minutes, y) end)
  #     r_square = Numerix.LinearRegression.r_squared(predicted, y)
  #     %{intercept: intercept, slope: slope, r2: r_square}
  #   else
  #     {:error}
  #   end
  # end

end
