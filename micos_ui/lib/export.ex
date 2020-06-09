defmodule Export do

  def csv() do
    # {:ok, table} = :dets.open_file(:qcl_data, [type: :set])
    # # ms = :ets.fun2ms fn {time, weight} -> [time, weight] end
    # data = :dets.select(table, [{{:"$1", :"$2"}, [], [[:"$1"]]}])
    #        |> Enum.sort
    #        |> CSV.encode
    #        |> Enum.to_list
    #        |> to_string
    # File.write("qcl.csv", data)
  end
end
