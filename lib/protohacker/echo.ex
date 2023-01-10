defmodule Protohacker.Echo do
  def handle(socket) do
    do_recv(socket,0)
  end

  defp do_recv(socket, length) do
    case :gen_tcp.recv(socket, length) do
      {:ok, data} ->
        :gen_tcp.send(socket, data)
        do_recv(socket,length)
      {:error, _msg} ->
        :gen_tcp.close(socket)
    end

  end
end
