defmodule Qcl.Logger do
  require Logger

  def save(msg) do
    #    Task.start(__MODULE__, :save_to_disk, [msg])
  end
  def save_to_disk(data) do
    {:ok, table} = :dets.open_file(:qcl_data, [type: :set])
    :dets.insert_new(table, {DateTime.utc_now, data})
    :dets.close(table)
  end
end
