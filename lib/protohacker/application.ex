defmodule Protohacker.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  use Application

  alias Protohacker.Echo
  alias Protohacker.TcpAcceptor
  alias Protohacker.PrimeTime
  alias Protohacker.MeansToAnEnd

  require Logger

  @impl true
  def start(_type, _args) do
    children = [
    #  %{id: TcpAcceptor, start: {TcpAcceptor,:start_link,[5555, &Echo.handle/1, []]}}
    # {Task, fn -> TcpAcceptor.start_link(5555, &Echo.handle/1, nil) end},
     # {Task, fn -> TcpAcceptor.start_link(5555, &PrimeTime.handle/1, [packet: :line, packet_size: 100_000, buffer: 100_000]) end},
     {Task, fn -> TcpAcceptor.start_link(5555, &MeansToAnEnd.handle/1, [packet: :raw, packet_size: 100_000, buffer: 100_000]) end},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

end
