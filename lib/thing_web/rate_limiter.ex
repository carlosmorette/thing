defmodule ThingWeb.RateLimiter do
  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> get_ip()
    |> check_ip()
  end

  defp get_ip(conn) do
    conn[:address]
    |> Tuple.to_list()
    |> Enum.join(".")
  end

  defp check_ip(ip) do
    case Hammer.check_rate(ip, 60_000, 3) do
      {:allow, _count} ->
        :allow

      {:deny, _limit} ->
        :deny
    end
  end
end
