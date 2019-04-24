defmodule Qcl.Reader do
  use GenServer

  require Logger

  alias Qcl.Parser

  def start_link(port) do
    GenServer.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    {:ok, pid} = Circuits.UART.start_link
    Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, %{uart: pid}}
  end

  def handle_info({:circuits_uart, "ttyUSB1", data}, state) do
    result = process_data(data)
    Logger.info inspect(result)
    {:noreply, Map.put(state, :result, result)}
  end

  def process_data(data) do
    Parser.parse(data)
  end
end
