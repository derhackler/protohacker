defmodule Protohacker.MeansToAnEnd do
  require Logger
  @packet_length 9

  def handle(socket) do
    do_recv(socket, @packet_length, [])
  end

  defp do_recv(socket, length, state) do
    case :gen_tcp.recv(socket, length) do
      {:ok, data} ->
        #Logger.debug(data)

        state = parse(state, socket, data)
        do_recv(socket, length, state)

      {:error, :closed} ->
        Logger.debug("socket closed")
    end
  end

  def parse(
        state,
        _socket,
        <<?I, timestamp::integer-signed-size(32), price::integer-signed-size(32)>>
      ) do
    # Logger.debug("insert timestamp: #{IO.inspect(timestamp)}, price: #{IO.inspect(price)}")
    [{timestamp, price} | state]
  end

  def parse(
        state,
        socket,
        <<?Q, mintime::integer-signed-size(32), maxtime::integer-signed-size(32)>>
      ) do
    # Logger.debug("query min: #{IO.inspect(mintime)}, max: #{IO.inspect(maxtime)}")

    result =
      state
      |> Enum.filter(fn {ts, _val} -> ts >= mintime && ts <= maxtime end)
      |> Enum.map(fn {_ts, val} -> val end)

    result =
      case Enum.count(result) do
        num when num == 0 -> 0
        num -> Integer.floor_div(Enum.sum(result), num)
      end

    # Logger.debug("about to send result: #{IO.inspect(result)}")
    :gen_tcp.send(socket, <<result::integer-signed-size(32)>>)
    state
  end

  def parse(state, socket, packet) do
    # Logger.debug("recived invalid packet: #{IO.inspect(packet)}")
    :gen_tcp.close(socket)
    state
  end
end
