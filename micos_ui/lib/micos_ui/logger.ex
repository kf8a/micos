defmodule MicosUi.Logger do
  require Logger

  def save(msg) do
    Task.start(__MODULE__, :write_to_rabbitmq, [msg])
  end

  @queue "micos_samples"
  @exchange "micos_samples"

  def open_connection() do
    config = Application.get_env(:amqp, Licor.Messenger)
    AMQP.Connection.open(host: config[:host],
                         virtual_host: "micos",
                         username: config[:user],
                         password: config[:password])
  end

  def write_to_rabbitmq(msg) do
    with {:ok, conn} = open_connection(),
         {:ok, chan} = AMQP.Channel.open(conn)
    do
      Logger.info "messenger sending #{inspect msg}"
      AMQP.Queue.declare(chan, @queue)
      AMQP.Exchange.declare(chan, @exchange )
      AMQP.Queue.bind(chan, @queue, @exchange)

      AMQP.Basic.publish( chan, @queue, "", :erlang.term_to_binary(msg))
      AMQP.Connection.close(conn)
    end
  end
end