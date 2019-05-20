
defmodule Licor.Parser do

  require Logger
  def parse(data) do
    Logger.debug "LICOR: data from port: #{inspect data}"
    doc = Exml.parse(data)
    Logger.debug "LICOR: parsed data: #{inspect doc}"
    %Licor{datetime: DateTime.utc_now, co2: co2(doc),
      temperature: temperature(doc), pressure: pressure(doc),
      co2_abs: co2_abs(doc), ivolt: ivolt(doc), raw: raw(doc)
    }
  end

  defp co2(doc) do
    extract(doc, "/li820/data/co2")
  end

  defp temperature(doc) do
    extract(doc, "//li820/data/celltemp")
  end

  defp pressure(doc) do
    extract(doc, "//li820/data/cellpres")
  end

  defp co2_abs(doc) do
    extract(doc, "//li820/data/co2abs")
  end

  defp ivolt(doc) do
    extract(doc, "//li820/data/ivolt")
  end

  defp raw(doc) do
    Exml.get(doc, "//li820/data/raw")
  end

  defp extract(doc, path) do
    Exml.get(doc, path)
    |> String.to_float
  end

end
