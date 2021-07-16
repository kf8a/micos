defmodule LabFlux.Result do
  defstruct seconds: 0,
    n2o_ppm: 0.0,
    n2o_ppm_dry: 0.0,
    n2o_ppm_slope: 0.0,
    n2o_ppm_intercept: 0.0,
    n2o_ppm_r2: 0.0,
    co2_ppm: 0.0,
    co2_ppm_slope: 0.0,
    co2_ppm_intercept: 0.0,
    co2_ppm_r2: 0.0,
    datetime: nil,
    h2o: 0.0,
    gas_temperature_c: 0.0
end
