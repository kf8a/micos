defmodule Licor.Reader do
  use GenServer

  require Logger

  alias Licor.Parser

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do
    {:ok, pid} = Circuits.UART.start_link
    Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, %{uart: pid}}
  end

  def current_value, do: GenServer.call(__MODULE__, :current_value)

  def handle_call(:current_value, _from, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_info({:circuits_uart, "ttyUSB0", data}, state) do
    result = process_data(data)
    Logger.info inspect(result)
    {:noreply, Map.put(state, :result, result)}
  end

  def process_data(data) do
    Parser.parse(data)
  end
end
