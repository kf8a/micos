alias NimbleCSV.RFC4180, as: CSV

defmodule Qcl.Parser do

  def parse(raw_data) do
    [data] = CSV.parse_string(raw_data, skip_headers: false)
    %{instrument_datetime: instrument_datetime(data), datetime: DateTime.utc_now,
      ch4_ppm: ch4_ppm(data), h2o_ppm: h2o_ppm(data), n2o_ppm: n2o_ppm(data),
      n2o_ppm_dry: n2o_ppm_dry(data), ch4_ppm_dry: ch4_ppm_dry(data)}
  end

  defp instrument_datetime(data) do
    {:ok, datetime} = Enum.fetch(data, 0)
    {:ok, date_list, _rest, _, _, _} = datetime
                                        |> String.trim
                                        |> Qcl.DatetimeParser.datetime

    [year, month, day, hour,minute, sec, millisec] = date_list
    {:ok, naive_date} = NaiveDateTime.new(year, month, day, hour, minute, sec, millisec*1000)
    {:ok, instrument_date} = DateTime.from_naive(naive_date, "Etc/UTC")
    instrument_date
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

defmodule Qcl.DatetimeParser do
  import NimbleParsec
  # 2019/04/24 17:15:48.530
  date =
    integer(4)
    |> ignore(string("/"))
    |> integer(2)
    |> ignore(string("/"))
    |> integer(2)

  time =
    integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string(":"))
    |> integer(2)
    |> ignore(string("."))
    |> integer(3)

  defparsec :datetime, date |> ignore(string(" ")) |> concat(time)
end