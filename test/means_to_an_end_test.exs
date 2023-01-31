defmodule MeansToAnEndTest do
  use ExUnit.Case
  require Logger

  def getNewConnection() do
    Logger.debug("about to connect...")
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 5003, [:binary, active: false])
    socket
  end

  def sendAndRecive(socket, payload) do
    Logger.debug("about so send...")
    :ok = :gen_tcp.send(socket, payload)

    Logger.debug("sent. try to receive answer...")
    {:ok, packet} = :gen_tcp.recv(socket, 0)

    Logger.debug("paylod sent:     '#{payload}'")
    Logger.debug("answer received: '#{packet}'")

    packet
  end


#TODO: Implement tests

end
