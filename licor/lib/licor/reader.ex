defmodule Licor.Reader do
  use GenServer

  alias Licor.Parser

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state) do
    {:ok, pid} = setup("ttyUSB0")
    {:ok, pid}
  end

  def setup(port) do
    {:ok, pid} = Circuits.UART.start_link
    Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, pid}
  end

  def handle_info({:circuits_uart, "ttyUSB0", data}, state) do
    process_data(data)
    {:noreply, state}
  end

  def read(pid) do
    receive do
      {:circuits_uart, _pid, data} ->
        process_data(data)

    end
    read(pid)
  end

  def process_data(data) do
    result = Parser.parse(data)
    IO.inspect result
  end
end
