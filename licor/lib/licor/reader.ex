defmodule Licor.Reader do
  use GenServer

  require Logger

  alias Licor.Parser

  def start_link(_) do
    port = get_port()
    GenServer.start_link(__MODULE__, %{port: port}, name: __MODULE__)
  end

  def init(%{port: port}) do
    IO.inspect port
    {:ok, pid} = Circuits.UART.start_link
    Circuits.UART.open(pid, port, speed: 9600, framing: {Circuits.UART.Framing.Line, separator: "\r\n"})
    {:ok, %{uart: pid, port: port, listeners: []}}
  end

  def get_port() do
    {port, _} = Circuits.UART.enumerate
                |> Enum.find({"LICOR_PORT", ''}, fn({_port, value}) -> correct_port?(value) end)

    port
  end

  def correct_port?(%{serial_number: number}) do
    number ==  "FTY3ZUKK"
  end

  def correct_port?(%{}) do
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

  def port, do: GenServer.call(__MODULE__, :port)

  def current_value, do: GenServer.call(__MODULE__, :current_value)

  def handle_call(:current_value, _from, %{result: result} = state) do
    {:reply, result, state}
  end

  def handle_call(:port, _from, %{port: port} = state) do
    {:reply, port, state}
  end

  def handle_info({:circuits_uart, port, data}, state) do
    if port == state[:port] do
      Task.start(__MODULE__, :process_data, [data, self()])
    end
    {:noreply, state}
  end

  def handle_info({:parser, result}, state) do
    Task.start(Licor.Logger, :save, [result])
    Logger.debug(inspect result)
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
