defmodule MicosUi.Instrument do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{sampling: false} end, name: __MODULE__)
  end

  def status() do
    Agent.get(__MODULE__, & &1)
  end

  def start() do
    Agent.update(__MODULE__, fn _state -> %{sampling: true} end)
  end

  def stop() do
    Agent.update(__MODULE__, fn _state -> %{sampling: false} end)
  end

  def cancel() do
    stop()
  end
end
