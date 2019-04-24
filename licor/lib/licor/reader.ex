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
    #<li820><data><celltemp>5.1464400e1</celltemp><cellpres>9.8119945e1</cellpres><co2>4.5745673e2</co2><co2abs>7.0640377e-2</co2abs><ivolt>1.7046508e1</ivolt><raw>3265640,3115406</raw></data></li820>
    co2 = Exml.get data, "/li820/data/co2"
    temperature = Exml.get data, "/li820/data/celltemp"
    # co2 = data |> xpath(~x"//li820/data/co2/text()")
    # temperature = data |> xpath(~x"//li820/data/celltemp/text()")
    # pressure = data |> xpath(~x"//li820/data/cellpres/text()")
    # co2_abs = data |> xpath(~x"//li820/data/co2abs/text()")
    # ivolt = data |> xpath(~x"//li820/data/ivolt/text()")
    # raw = data |> xpath(~x"//li820/data/raw/text()")
    IO.inspect %{datetime: DateTime.utc_now, co2: co2, temperature: temperature}
  end
end
