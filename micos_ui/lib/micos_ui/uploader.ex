defmodule MicosUi.Uploader do
 	use GenServer

  require Logger
  alias MicosUi.Samples
  alias MicosUi.Points
  alias MicosUi.Repo

  @config Application.get_env(:amqp, MicosUi.Uploader)
  @sample_queue "micos_sample_queue"
  @sample_exchange "micos_sample_exchange"
  @point_queue "micos_point_queue"
  @point_exchange "micos_point_exchange"

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    Process.send_after(self(), :upload, 30_000)
    {:ok, state}
  end

  def handle_info(:upload, state) do
    Process.send_after(self(), :upload, 600_000)

    options = [host: @config[:host], port: @config[:port], virtual_host: @config[:virtual_host],
      username: @config[:username], password: @config[:password]]
    msg =
      with {:ok, conn} <- AMQP.Connection.open(options),
           {:ok, chan} <- AMQP.Channel.open(conn),
           do: upload_samples(chan)

    Logger.info inspect(msg)
    {:noreply, state}
  end

  defp upload_samples(chan) do
    msg =
      with AMQP.Queue.declare(chan, @sample_queue, [durable: true]),
           AMQP.Queue.declare(chan, @point_queue, [durable: true]),
           AMQP.Exchange.declare(chan, @sample_exchange),
           AMQP.Exchange.declare(chan, @point_exchange),
           AMQP.Queue.bind(chan, @sample_queue, @sample_exchange),
           AMQP.Queue.bind(chan, @point_queue, @point_exchange)
      do

        Samples.list_samples_to_upload()
        |> Enum.each(fn(x) -> upload_sample(chan, x) end)

        Points.list_points_to_upload()
        |> Enum.each(fn(x) -> upload_point(chan, x) end )
      end
  end

  defp upload_sample(chan, sample) do
    with :ok = AMQP.Basic.publish(chan, @sample_exchange, "",  :erlang.term_to_binary(sample)) do
      Ecto.Changeset.change(sample, %{uploaded: true})
      |> Repo.update()
    end
  end

  defp upload_point(chan, point) do
    with :ok = AMQP.Basic.publish(chan, @point_exchange, "",  :erlang.term_to_binary(point)) do
      Ecto.Changeset.change(point, %{uploaded: true})
      |> Repo.update()
    end
  end
end
