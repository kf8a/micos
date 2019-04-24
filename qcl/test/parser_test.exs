defmodule ParserTest do
  use ExUnit.Case

  setup _context do
    data = "  2019/04/24 17:15:48.530,   1.944437e+00,   0.000000e+00,   4.709688e+03,   0.000000e+00,   3.366223e-01,   0.000000e+00,   3.382152e-01,   0.000000e+00,   1.953638e+00,   0.000000e+00,   4.499816e+01,   0.000000e+00,   3.343601e+01,   0.000000e+00,   3.389675e+01,   0.000000e+00,   2.823585e-01,   0.000000e+00,   1.065110e+00,   0.000000e+00,   9.983344e-01,   0.000000e+00,  -1.621646e+00,   0.000000e+00,              3,             -1,       Disabled"
    result = Qcl.Parser.parse(data)
    result
  end

  test "parsing for instrument datetime", context do
    assert context[:instrument_datetime] == ~N[2019-04-24 17:15:48.530000]
  end

  test "parsing for ch4_ppm", context do
    assert context[:ch4_ppm] == 1.944437
  end

  test "parsing for n2o_ppm", context do
    assert context[:n2o_ppm] == 0.3366223
  end
  test "parsing for n2o_ppm_dry",context do
    assert context[:n2o_ppm_dry] == 0.3382152
  end
  test "parsing for ch4_ppm_dry",context do
    assert context[:ch4_ppm_dry] == 1.953638
  end
  test "parsing for h2o_ppm", context do
    assert context[:h2o_ppm] == 4709.688
  end

  test "date time parsing" do
    data = "2019/04/24 17:15:48.530"
    {:ok, result, _ , _, _, _ } = Qcl.DatetimeParser.datetime(data)
    assert result == [2019, 4, 24, 17, 15, 48, 530]
  end
end
