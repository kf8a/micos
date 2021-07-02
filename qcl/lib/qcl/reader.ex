defmodule Qcl.Reader do
  use GenServer

  require Logger

  alias Qcl.Parser

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{port_serial: "FTB3L9SF"}, name: __MODULE__)
  end

  def init(%{port_serial: serial_number}) do
    {:ok, pid} = Circuits.UART.start_link
    case find_port(Circuits.UART.enumerate, serial_number) do
      {port, _ } ->
        Circuits.UART.open(pid, port, speed: 9600, parity: :none, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
        {:ok, %{uart: pid, port: port, listeners: []}}
      nil ->
        {:ok, %{uart: pid, port: nil, listeners: []}}
    end
  end

  def find_port(ports, serial_number) do
    ports
    |> Enum.find(fn({_port, value}) -> correct_port?(value, serial_number) end)
  end

  def correct_port?(%{serial_number: number}, serial_number) do
    number ==  serial_number
  end

  def correct_port?(%{}, _serial_port) do
    false
  end

  def register(client_pid) do
    GenServer.cast(__MODULE__, {:register, client_pid})
  end

  def unregister(client_pid) do
    GenServer.cast(__MODULE__, {:unregister, client_pid})
  end

  def process_data(data, pid) do
    result = Parser.parse(data)
    Process.send(pid, {:parser, result}, [])
  end

  def broadcast(result, listeners) do
    Enum.map(listeners, fn x -> Process.send(x, result, []) end)
  end

  def current_value, do: GenServer.call(__MODULE__, :current_value)

  def handle_call(:current_value, _from, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_info({:circuits_uart, port, data}, state) do
    if port == state[:port] do
      Task.start(__MODULE__, :process_data, [data, self()])
    end
    {:noreply, state}
  end

  def handle_info({:parser, result}, state) do
    Task.start(Qcl.Logger, :save, [result])
    Logger.debug inspect(result)
    broadcast(result, state[:listeners])
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
