defmodule Protohacker.EchoserverAcceptor do
  require Logger
  use GenServer


  def start_link(_param) do
    GenServer.start_link(__MODULE__,nil)
  end

  # runs in the process of the server:

  @impl true
  @spec init(any) :: {:ok, nil, {:continue, nil}}
  def init(_) do
    {:ok, nil, {:continue, nil}}
  end

  @impl true
  def handle_continue(_arg,_state) do
    {:ok, listen_socket} =:gen_tcp.listen(5555, [:binary, packet: :line, active: false, reuseaddr: true])
    loop_acceptor(listen_socket)
    {:noreply, nil}
  end


  def loop_acceptor(listen_socked) do
    {:ok, client} = :gen_tcp.accept(listen_socked)

    spawn(fn ->
      do_recv(client, 0)
    end)

    loop_acceptor(listen_socked)
  end

  defp do_recv(client_socket, length) do
    case :gen_tcp.recv(client_socket, length) do
      {:ok, data} ->
        :gen_tcp.send(client_socket, data)
    end

    do_recv(client_socket,length)
  end



end
