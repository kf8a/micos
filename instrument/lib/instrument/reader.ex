defmodule Instrument.Reader do
  use GenServer

  alias Instrument.Logger
  alias Qcl

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{licor: %{}, data: %Instrument{}}, name: Instrument.Reader)
  end

  def init(state) do
    Process.send_after(self(), :register, 1000)
    {:ok, state}
  end

  def handle_info(:register, state) do
    Licor.Reader.register(self())
    Qcl.Reader.register(self())
    {:noreply, state}
  end

  def handle_info(%Licor{}=data, state) do
    {:noreply, Map.put(state, :licor, data)}
  end

  def handle_info(%Qcl{}=qcl, state) do
    state = case state[:licor] do
      %{} ->  state
      _ ->
        datum = %{datetime: qcl[:datetime], ch4: qcl[:ch4_ppm_dry], n2o: qcl[:n2o_ppb_dry], co2: state[:licor][:co2]}
        Logger.save(datum)
        # emit data
        Map.put(state, :data, datum)
    end
    {:noreply, state}
  end
end
