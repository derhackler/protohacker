defmodule EchoTest do
  use ExUnit.Case
  require Logger

  def getNewConnection() do
    Logger.debug("about to connect...")
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 5555, [:binary, active: false])
    socket
  end

  def send(socket, payload) do
    Logger.debug("connected. about so send...")
    :ok = :gen_tcp.send(socket, payload)

    Logger.debug("sent. try to receive answer...")
    {:ok, packet} = :gen_tcp.recv(socket, 0)

    Logger.debug("paylod sent:     '#{payload}'")
    Logger.debug("answer received: '#{packet}'")

    packet
  end

  test "single connection" do
    socket = getNewConnection()
    payload = "test payload"
    answer = EchoTest.send(socket, payload)
    assert payload == answer
    :gen_tcp.close(socket)
  end

  test "2 connections" do
    socket1 = getNewConnection()
    socket2 = getNewConnection()
    payload1 = "foo bar"
    payload2 = "1234567890"

    answer1 = EchoTest.send(socket1, payload1)
    answer2 = EchoTest.send(socket2, payload2)

    assert payload1 == answer1
    assert payload2 == answer2

    :gen_tcp.close(socket1)
    :gen_tcp.close(socket2)
  end
end
