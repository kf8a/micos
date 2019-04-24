defmodule Licor.DataSource do
  use GenStage

  def start_link(reader) do
        GenStage.start_link(Licor, reader)
  end

  def init(reader) do
    {:producer, reader}
  end

  def handle_demand(demand, reader) when demand > 0 do
    {:noreply, reader.current_value, reader }
  end

end
