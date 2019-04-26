defmodule MicosUi.InstrumentTest do
  use ExUnit.Case

  alias MicosUi.Instrument
  test "can start a sample" do
    Instrument.start()
    assert Instrument.status == %{sampling: true}
  end

  test "can stop a sample" do
    Instrument.stop()
    assert Instrument.status == %{sampling: false}
  end
end
