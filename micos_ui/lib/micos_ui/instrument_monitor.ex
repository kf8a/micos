defmodule MicosUi.InstrumentMonitor do
  @moduledoc """
  Monitor to make the instrument data available on request
  collects every 3rd point so that we can look for longer trends
  without having too much data to plot.
  """

  use GenStage

  @buffer_size 500

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  subscribe the the instrument producer
  """
  def init(:ok) do
    {:consumer,
     %{
       producer: Instrument.Producer,
       current_value: nil,
       values: [],
       counter: 0
     }, subscribe_to: [{Instrument.Producer, []}]}
  end

  def current_value() do
    GenStage.call(__MODULE__, :current_value)
  end

  def values() do
    GenStage.call(__MODULE__, :values)
  end

  def handle_call(:current_value, _from, state) do
    {:reply, state[:current_value], [], state}
  end

  def handle_call(:values, _from, state) do
    {:reply, state[:values], [], state}
  end

  def handle_events(events, _from, state) when is_list(events) and length(events) > 0 do
    temp_state = Map.put(state, :counter, rem(state[:counter] + 1, 3))

    case temp_state[:counter] do
      0 ->
        # events handling here

        current = List.first(events)

        new_values =
          [events | state[:values]]
          |> List.flatten()
          |> limit_list_size(@buffer_size)

        new_state =
          temp_state
          |> Map.put(:current_value, current)
          |> Map.put(:values, new_values)

        {:noreply, [], new_state}

      _ ->
        {:noreply, [], temp_state}
    end
  end

  defp limit_list_size(my_list, size) do
    case length(my_list) > size do
      false ->
        my_list

      true ->
        my_list
        |> Enum.reverse()
        |> tl()
        |> Enum.reverse()
        |> limit_list_size(size)
    end
  end
end
