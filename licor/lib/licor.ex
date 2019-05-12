defmodule Licor do
  @moduledoc """
  Licor reader
  """
  defstruct source: :licor, datetime: DateTime.utc_now(), co2: 0, temperature: 0,
    pressure: 0, co2_abs: 0, ivolt: 0, raw: 0
end
