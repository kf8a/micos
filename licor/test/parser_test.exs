defmodule LicorParserTest do
  use ExUnit.Case

  test "parse the whole data string" do
    data = "<li820><data><celltemp>5.1464400e1</celltemp><cellpres>9.8119945e1</cellpres><co2>4.5745673e2</co2><co2abs>7.0640377e-2</co2abs><ivolt>1.7046508e1</ivolt><raw>3265640,3115406</raw></data></li820>"
    result = Licor.Parser.parse(data)
    assert result[:co2] == 457.45673
    assert result[:temperature] == 51.464400
    assert result[:pressure] == 9.8119945e1
    assert result[:co2_abs] == 7.0640377e-2
    assert result[:ivolt] == 1.7046508e1
    assert result[:raw] == "3265640,3115406"
  end
end
