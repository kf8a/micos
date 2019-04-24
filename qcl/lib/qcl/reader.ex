defmodule Qcl.Reader do
  use GenServer

  require Logger

  alias Qcl.Parser

  @port Application.get_env(:qcl, :port)

  def start_link(_) do
    GenServer.start_link(__MODULE__, @port, name: __MODULE__)
  end

  def init(port) do
    {:ok, pid} = Circuits.UART.start_link
    Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, %{uart: pid}}
  end

  def current_value, do: GenServer.call(__MODULE__, :current_value)

  def handle_call(:current_value, _from, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_info({:circuits_uart, @port, data}, state) do
    result = process_data(data)
    Logger.info inspect(result)
    {:noreply, Map.put(state, :result, result)}
  end

  def process_data(data) do
    Parser.parse(data)
  end
end
