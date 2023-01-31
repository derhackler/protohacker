defmodule Protohacker.BudgetChat do
  require Logger

  use GenServer

  def start_link(socket) do
    GenServer.start_link(__MODULE__, socket, [])
  end


  @impl true
  def init(socket) do
    {:ok, %{socket: socket, name: ""}, {:continue, :send_welcome}}
  end

  @impl true
  def handle_continue(:send_welcome, state)  do
    welcome_message() |> send_msg(state.socket)
    {:noreply, state, {:continue, :set_clientname}}
  end


  @impl true
  def handle_continue(:set_clientname, %{socket: socket, name: ""}) do
    case set_client_name(socket) do
      {:ok, name} ->
        user_joined(name) |> send_msg(socket)
        {:noreply, %{socket: socket, name: name}}
      {:error, msg} ->
        msg |> send_msg(socket)
        close_silently(socket)
        {:stop, :normal}
    end
  end

  def welcome_message() do
    "Welcome to budgetchat! What shall I call you?"
  end

  def user_joined(username) do
      # trim \n
      "* #{username} has joined"
  end

  def set_client_name(socket) do
    :gen_tcp.recv(socket, 0)
  end

  def close_silently(socket) do
    :gen_tcp.close(socket)
  end


  def send_msg(msg,socket) do
    case :gen_tcp.send(socket, msg) do
      :ok-> socket
      {:error,reason} ->
        Logger.debug("sending failed with reason: #{IO.inspect(reason)}")
        socket
    end
  end




end
