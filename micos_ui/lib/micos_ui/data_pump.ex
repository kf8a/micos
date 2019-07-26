# subscribe to the instrument and broadcast co2 data to the frontend
defmodule MicosUi.DataPump do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: MicosUi.DataPump)
  end

  def init(state) do
    Instrument.register(self)
    {:ok, state}
  end

  def handle_info(%Instrument{co2: co2, datetime: datetime} = datum, state) do
    broadcast(datetime, co2)
    {:noreply, state}
  end

  defp broadcast(time, co2) do
    MicosUiWeb.Endpoint.broadcast! "data:update", "new_data", %{
      time: time,
      co2: co2,
    }
  end
end
