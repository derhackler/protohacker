defmodule Protohacker.PrimeTime do
  require Logger

  def handle(socket) do
    do_recv(socket, 0)
  end

  defp do_recv(socket, length) do
    case :gen_tcp.recv(socket, length) do
      {:ok, data} ->
        Logger.info(data)

        with {:ok, json} when is_map(json)                                        <- Jason.decode(data),
             %{"method" => "isPrime", "number" => number} when is_number(number)  <- json do

          resp = Jason.encode!(%{"method" => "isPrime", "prime" => is_prime?(number)}) <> "\n"
          Logger.info(resp)

          :gen_tcp.send(
            socket,
            resp
          )

          do_recv(socket, length)
        else
          _ ->
            Logger.info("malformed")
            :gen_tcp.send(socket, "malformed\n")
            :gen_tcp.shutdown(socket, :read_write)
        end
    end
  end

  defp is_prime?(n) when is_float(n), do: false
  defp is_prime?(n) when n < 0, do: false
  defp is_prime?(n) when n in [2, 3], do: true

  defp is_prime?(n) do
    floored_sqrt =
      :math.sqrt(n)
      |> Float.floor()
      |> round

    !Enum.any?(2..floored_sqrt, &(rem(n, &1) == 0))
  end
end
