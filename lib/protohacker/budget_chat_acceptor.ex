defmodule Protohacker.BudgetChatAcceptor do
  require Logger

  def start_link(port, options \\ []) do

    options = Keyword.merge([packet: :raw, active: false, reuseaddr: true], options)
    # handler is a function that should be called to dispatch the socket to
    # it's then on its own
    # ideally ther is a pool of acceptors so that connections
    # can be established in parallel
    Task.start_link(fn ->
      {:ok, listen_socket} =:gen_tcp.listen(port, [:binary | options] )
      accept(listen_socket)
    end)

  end

  def accept(listen_socket) do
    {:ok, socket} = :gen_tcp.accept(listen_socket) |> IO.inspect()
    DynamicSupervisor.start_child(TcpConnections, {Protohacker.BudgetChat, socket} )
    accept(listen_socket)
  end



end
