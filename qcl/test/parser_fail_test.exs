defmodule ParserFailTest do
  use ExUnit.Case
  use ExUnitProperties

  test 'fails on malformed data' do
      check all data <- StreamData.string(:printable) do
      assert {:error, _ } = Qcl.Parser.parse(data)
      # assert_raise NimbleCSV.ParseError, fn -> Qcl.Parser.parse(data) end
    end
  end

end
