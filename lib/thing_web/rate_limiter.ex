defmodule ThingWeb.RateLimiter do
  import Phoenix.Controller
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> get_ip()
    |> check_ip()
    |> case do
      :allow ->
        conn

      :deny ->
        conn
        |> put_view(ThingWeb.RateLimiterView)
        |> render("rate_limiter.html")
        |> halt()
    end
  end

  defp get_ip(conn) do
    conn.remote_ip
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
