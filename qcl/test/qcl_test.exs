defmodule QclTest do
  use ExUnit.Case
  doctest Qcl

  test "parsing the data" do
    File.stream("../data/qcl.dat")

  end

end
