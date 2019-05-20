defmodule ParserFailTest do
  use ExUnit.Case
  use ExUnitProperties

  test 'fails on malformed data' do
    check all data <- StreamData.binary() do
      result = Qcl.Parser.parse(data)
      assert {:error, _ } = result
    end
  end

end
