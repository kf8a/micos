defmodule Instrument do
  @moduledoc """
  Documentation for Instrument.
  """

  defstruct datetime: DateTime.utc_now, co2: 0.0, n2o: 0.0, ch4: 0.0, minute: 0.0

  defdelegate register(client_pid), to: Instrument.Reader
  defdelegate unregister(client_pid), to: Instrument.Reader
end
