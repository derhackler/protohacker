defmodule PrimeTimeTest do
  use ExUnit.Case
  require Logger

  @malformed "malformed\n"
  @max_packet_size 100_000

  def getNewConnection() do
    Logger.debug("about to connect...")
    {:ok, socket} = :gen_tcp.connect('127.0.0.1', 5002, [:binary, active: false])
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

  def sendValidPayload(number) do
    socket = getNewConnection()
    rawAnswer = PrimeTimeTest.sendAndRecive(socket, "{\"method\": \"isPrime\", \"number\": #{number}}\n")
    {:ok, answer} = Jason.decode(rawAnswer)
    {socket, answer}
  end


  test "single connection empty payload" do
    socket = getNewConnection()
    assert @malformed == PrimeTimeTest.sendAndRecive(socket, "\n")
    assert {:error, :closed} == :gen_tcp.recv(socket, 0)
    :gen_tcp.close(socket)
  end

  test "single connection malformed JSON" do
    socket = getNewConnection()
    assert @malformed == PrimeTimeTest.sendAndRecive(socket, "{\"method\": \"isPrime\"\n")
    assert {:error, :closed} == :gen_tcp.recv(socket, 0)
    :gen_tcp.close(socket)
  end

  test "single connection malformed payload format" do
    socket = getNewConnection()
    assert @malformed == PrimeTimeTest.sendAndRecive(socket, "{\"method\": \"isPrime\", \"number\": \"foo\"}\n")
    assert {:error, :closed} == :gen_tcp.recv(socket, 0)
    :gen_tcp.close(socket)
  end

  test "single connection valid paylod non prime" do
    socket = getNewConnection()
    rawAnswer = PrimeTimeTest.sendAndRecive(socket, "{\"method\": \"isPrime\", \"number\": 4}\n")
    {:ok, answer} = Jason.decode(rawAnswer)
    assert answer["method"] == "isPrime"
    assert answer["prime"] == false
    :gen_tcp.close(socket)
  end

  test "single connection valid paylod prime" do
    {socket, answer}  = sendValidPayload(7)
    assert answer["method"] == "isPrime"
    assert answer["prime"] == true
    :gen_tcp.close(socket)
  end

  test "single connection valid paylod 0" do
    {socket, answer} = sendValidPayload(0)
    assert answer["method"] == "isPrime"
    assert answer["prime"] == false
    :gen_tcp.close(socket)
  end



  test "single connection valid paylod negative number" do
    {socket, answer}  = sendValidPayload(-12)
    assert answer["method"] == "isPrime"
    assert answer["prime"] == false
    :gen_tcp.close(socket)
  end

  test "single connection valid paylod float" do
    {socket, answer}  = sendValidPayload(-12.12345)
    assert answer["method"] == "isPrime"
    assert answer["prime"] == false
    :gen_tcp.close(socket)
  end

  test "single connection valid paylod in two packets" do
    socket = getNewConnection()
    :ok = :gen_tcp.send(socket, "{\"method\": \"isPrime\",")
    :ok = :gen_tcp.send(socket, "\"number\": 3}\n")

    {:ok, rawAnswer} = :gen_tcp.recv(socket, 0)
    {:ok, answer} = Jason.decode(rawAnswer)

    assert answer["method"] == "isPrime"
    assert answer["prime"] == true

    :gen_tcp.close(socket)
  end

  test "single connection valid very long payload" do
    socket = getNewConnection()
    :ok = :gen_tcp.send(socket, "{\"method\": \"isPrime\"," <>  String.duplicate(" ",  @max_packet_size - 10_000))
    :ok = :gen_tcp.send(socket, "\"number\": 3}\n")

    {:ok, rawAnswer} = :gen_tcp.recv(socket, 0)
    {:ok, answer} = Jason.decode(rawAnswer)

    assert answer["method"] == "isPrime"
    assert answer["prime"] == true

    :gen_tcp.close(socket)
  end

  test "2 concurrent connections" do
    socket1 = getNewConnection()
    socket2 = getNewConnection()
    :ok = :gen_tcp.send(socket1, "{\"method\": \"isPrime\"," )
    :ok = :gen_tcp.send(socket2, "foo")
    :ok = :gen_tcp.send(socket1, "\"number\": 13}\n")
    :ok = :gen_tcp.send(socket2, "bar\n")

    {:ok, rawAnswer1} = :gen_tcp.recv(socket1, 0)
    {:ok, rawAnswer2} = :gen_tcp.recv(socket2, 0)

    {:ok, answer1} = Jason.decode(rawAnswer1)
    assert answer1["method"] == "isPrime"
    assert answer1["prime"] == true
    assert rawAnswer2 == @malformed

    :gen_tcp.close(socket1)
    :gen_tcp.close(socket2)
  end


end
