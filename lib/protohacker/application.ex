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
      %{id: :challange1_echo,             start: {TcpAcceptor, :start_link, [5001, &Echo.handle/1, []]}},
      %{id: :challange2_prime_time,       start: {TcpAcceptor, :start_link, [5002, &PrimeTime.handle/1, [packet: :line, packet_size: 100_000, buffer: 100_000]]}},
      %{id: :challange3_means_to_an_end,  start: {TcpAcceptor, :start_link, [5003, &MeansToAnEnd.handle/1, [packet: :raw, packet_size: 100_000, buffer: 100_000]]}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

end
