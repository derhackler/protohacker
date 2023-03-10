defmodule Protohacker.TcpAcceptor do
  alias Protohacker.BudgetChat
  require Logger

  def start_link(port, handler, options \\ []) do

    options = Keyword.merge([packet: :raw, active: false, reuseaddr: true], options)
    # handler is a function that should be called to dispatch the socket to
    # it's then on its own
    # ideally ther is a pool of acceptors so that connections
    # can be established in parallel
    Task.start_link(fn ->
      {:ok, listen_socket} =:gen_tcp.listen(port, [:binary | options] )
      accept(listen_socket, handler)
    end)

  end

  def accept(listen_socket,handler) when is_function(handler, 1) do
    {:ok, socket} = :gen_tcp.accept(listen_socket) |> IO.inspect()
    # this is not really great. spawn does not create a monitored process.
    spawn(fn -> handler.(socket) end)

    accept(listen_socket, handler)

  end



end
