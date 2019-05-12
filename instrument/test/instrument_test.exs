defmodule InstrumentTest do
  use ExUnit.Case
  doctest Instrument

  test "greets the world" do
    assert Instrument.hello() == :world
  end
end
