defmodule Instrument do
  @moduledoc """
  Documentation for Instrument.
  """

  defstruct datetime: DateTime.utc_now, co2: 0, n2o: 0, ch4: 0

  def register() do
  end

  def unregister() do
  end
end
