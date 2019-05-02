defmodule Licor.Logger do
  def save(data) do
    {:ok, table} = :dets.open_file(:licor_storage, [type: :set])
    :dets.insert_new(table, {DateTime.utc_now, data})
    :dets.close(table)
  end
end
