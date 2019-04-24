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
