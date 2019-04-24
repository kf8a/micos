defmodule LicorReader do
  use GenServer

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state) do

    {:ok, state}
  end

  def setup(port) do
    {:ok, pid} = Circuits.UART.start_link
    Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, pid}
  end

  def read(pid) do
    receive do
      {:circuits_uart, pid, data} ->
        process_data(pid,data)

    end
    read(pid)
  end

  def process_data(_pid, data) do
    IO.inspect data
  end
end
