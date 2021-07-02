defmodule MicosUiTemperatureUpdater do
  def get_air_temperature(datetime) do

    query = "https://lter.kbs.msu.edu/weather/five_minute_observations.js?datetime=#{datetime}"
    case HTTPoison.get(query) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        IO.puts body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end
end
