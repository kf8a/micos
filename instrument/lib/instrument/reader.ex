defmodule Instrument.Reader do
  use GenServer

  require Logger

  def start_link(debug \\ false) do
    GenServer.start_link(__MODULE__, %{debug: debug, licor: %{}, data: %Instrument{}, listeners: []}, name: Instrument.Reader)
  end

  def init(state) do
    case state[:debug] do
      true ->
        Process.send_after(__MODULE__, :tick, 1_000)
      false ->
        Licor.Reader.register(self())
        Qcl.Reader.register(self())
    end
    {:ok, state}
  end

  def register(client_pid) do
    GenServer.cast(__MODULE__, {:register, client_pid})
  end

  def unregister(client_pid) do
    GenServer.cast(__MODULE__, {:unregister, client_pid})
  end

  def broadcast(result, listeners) do
    Enum.map(listeners, fn x -> Process.send(x, result, []) end)
  end

  def handle_info(:tick, state) do
    number = :rand.uniform(1000)/1000
    datum = %Instrument{datetime: DateTime.utc_now(), ch4: number, n2o: number, co2: number}
    broadcast(datum, state[:listeners])
    Process.send_after(__MODULE__, :tick, 1_000)
    {:noreply, state}
  end

  def handle_info(%Licor{} = data, state) do
    {:noreply, Map.put(state, :licor, data)}
  end

  def handle_info(%Qcl{} = qcl, state) do
    licor = state[:licor]
    state = case licor do
      %Licor{} ->
        datum = %Instrument{datetime: qcl.datetime, ch4: qcl.ch4_ppm_dry, n2o: qcl.n2o_ppb_dry, co2: licor.co2}
        Instrument.Logger.save(datum)
        broadcast(datum, state[:listeners])
        Map.put(state, :data, datum)
      _ ->
        Logger.warn "unkown state #{inspect state}"
        state
    end
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info "Unexpected message: #{inspect msg}"
    {:noreply, state}
  end

  def handle_cast({:register, pid}, state) do
    listeners = state[:listeners] ++ [ pid ]
    {:noreply, Map.put(state, :listeners, listeners)}
  end

  def handle_cast({:unregister, pid}, state) do
    listeners = List.delete(state[:listeners],   pid)
    {:noreply, Map.put(state, :listeners, listeners)}
  end

end
