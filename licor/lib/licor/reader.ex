defmodule Licor.Reader do
  use GenServer

  require Logger

  alias Licor.Parser

  @port Application.get_env(:licor, :port)

  def start_link(_) do
    GenServer.start_link(__MODULE__, @port, name: __MODULE__)
  end

  def init(port) do
    subscribe([])
    {:ok, pid} = Circuits.UART.start_link

    Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, {%{uart: pid, listeners: []}}
  end

  def register(client_pid) do
    GenServer.cast(__MODULE__, :register, client_pid)
  end

  def unregister(client_pid) do
    GenServer.cast(__MODULE__, :unregister, client_pid)
  end

  def process_data(data) do
    Parser.parse(data)
  end

  def broadcast(result, state) do
    state[:listeners]
    |> Enum.map(fn x -> send x result end)
  end

  def current_value, do: GenServer.call(__MODULE__, :current_value)

  def handle_call(:current_value, _from, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_info({:circuits_uart, @port, data}, state) do
    result = process_data(data)
    Logger.debug inspect(result)
    broadcast(result)
    {:noreply, Map.put(state, :result, result)}
  end

  def handle_cast(:register, pid, state) do
    listeners = state[:listeners] ++ [ pid ]
    {:noreply, Map.put(state, :listeners, listeners)}
  end

  def handle_cast(:unregister, pid, state) do
    listeners = List.delete(state[:listeners],   pid)
    {:noreply, Map.put(state, :listeners, listeners)}
  end
end
