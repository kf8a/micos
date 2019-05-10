defmodule Licor.Logger do
  require Logger

  def save(msg) do
    # msg = Map.put(data, :datetime, DateTime.utc_now)
    Task.start(__MODULE__, :save_to_disk, [msg])
    Task.start(__MODULE__, :write_to_rabbitmq, [msg])
  end

  def save_to_disk(data) do
    {:ok, table} = :dets.open_file(:licor_data, [type: :set])
    :dets.insert_new(table, {DateTime.utc_now, data})
    :dets.close(table)
  end

  @queue "micos_licor"
  @exchange "micos_licor"

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
      Logger.debug "messenger sending #{inspect msg}"
      AMQP.Queue.declare(chan, @queue)
      AMQP.Exchange.declare(chan, @exchange )
      AMQP.Queue.bind(chan, @queue, @exchange)

      AMQP.Basic.publish( chan, @queue, "", :erlang.term_to_binary(msg))
      AMQP.Connection.close(conn)
    end
  end
end
