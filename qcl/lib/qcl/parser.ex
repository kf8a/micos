alias NimbleCSV.RFC4180, as: CSV

defmodule Qcl.Parser do

  require Logger

  alias Qcl.DatetimeParser

  def parse(raw_data) do
    data = case CSV.parse_string(raw_data, skip_headers: false) do
      [datum] -> datum
      datum -> datum
    end
    if n2o_ppm(data) == 0  do
      Logger.debug "QCL parsed data: #{inspect data}"
      Logger.debug "QCL data from port: #{inspect raw_data}"
    end

    case instrument_datetime(data) do
      {:ok, datetime } ->
        %Qcl{instrument_datetime: datetime, datetime: DateTime.utc_now,
          ch4_ppm: ch4_ppm(data), h2o_ppm: h2o_ppm(data), n2o_ppm: n2o_ppm(data),
          n2o_ppm_dry: n2o_ppm_dry(data), ch4_ppm_dry: ch4_ppm_dry(data),
          n2o_ppb_dry: n2o_ppm_dry(data)*1000}
    end
  end

  defp instrument_datetime(data) when length(data) > 10 do
    {:ok, datetime} = Enum.fetch(data, 0)
    case parse_datetime(datetime) do
      {:ok, date_list, _rest, _, _, _} ->
        [year, month, day, hour,minute, sec, millisec] = date_list
        NaiveDateTime.new(year, month, day, hour, minute, sec, millisec*1000)
      {:error, msg} ->
            {:error, msg}
    end
  end

  defp instrument_datetime(data) do
    {:error, "No data to process #{inspect data}"}
  end

  defp parse_datetime(datetime)  do
    datetime
    |> String.trim
    |> DatetimeParser.datetime
  end

  defp ch4_ppm(data) do
    extract(data, 1)
  end

  defp h2o_ppm(data) do
    extract(data, 3)
  end

  defp n2o_ppm(data) do
    extract(data, 5)
  end

  defp n2o_ppm_dry(data) do
    extract(data, 7)
  end

  defp ch4_ppm_dry(data) do
    extract(data, 9)
  end

  def extract(data, index) do
    {:ok, value } = Enum.fetch(data, index)
    value
    |> String.trim
    |> String.to_float
  end
end

