defmodule Qcl do

  defstruct instrument_datetime: DateTime.utc_now(), datetime: DateTime.utc_now(),
      ch4_ppm: 0, h2o_ppm: 0, n2o_ppm: 0, n2o_ppm_dry: 0, ch4_ppm_dry: 0,
      n2o_ppb_dry: 0
end
