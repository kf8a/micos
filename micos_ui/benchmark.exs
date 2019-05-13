list = Enum.to_list(1..10_000)
map_fun = fn i -> [i * i] end
y =  Enum.flat_map(list, map_fun)

defmodule BenchmarkTest do
  def manual(minutes, y) do
    data = Enum.zip(minutes, y)
  end

  def numerix(minutes, y) do
    {intercept, slope} = Numerix.LinearRegression.fit(minutes,y)
    predicted = Enum.map(minutes, fn(z) -> Numerix.LinearRegression.predict(z, minutes, y) end)
    r_square = Numerix.LinearRegression.r_squared(predicted, y)
    %{intercept: intercept, slope: slope, r2: r_square}
  end
end

Benchee.run(%{
  # "manual" => fn -> BenchmarkTest.manual(list, y) end,
  "numerix" => fn -> BenchmarkTest.numerix(list, y) end
})
