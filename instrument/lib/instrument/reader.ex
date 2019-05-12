defmodule Instrument.Reader do
  use GenServer

  require Logger

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
    licor = state[:licor]
    state = case licor do
      %Licor{} ->
        datum = %{datetime: qcl.datetime, ch4: qcl.ch4_ppm_dry, n2o: qcl.n2o_ppb_dry, co2: licor.co2}
        Instrument.Logger.save(datum)
        # emit data
        Map.put(state, :data, datum)
      _ ->
        Logger.warn "unkown state #{inspect state}"
    end
    {:noreply, state}
  end
end
