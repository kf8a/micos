defmodule Licor.Reader do
  use GenServer

  require Logger

  alias Licor.Parser

  @port Application.get_env(:licor, :port)

  def start_link(_) do
    GenServer.start_link(__MODULE__, @port, name: __MODULE__)
  end

  def init(port) do
    {:ok, pid} = Circuits.UART.start_link

    Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, %{uart: pid, listeners: []}}
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

  def handle_info({:circuits_uart, @port, data}, state) do
    Task.start(__MODULE__, :process_data, [data, self()])
    {:noreply, state}
  end

  def handle_info({:parser, result}, state) do
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
