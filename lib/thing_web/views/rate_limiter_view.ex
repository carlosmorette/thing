defmodule ThingWeb.RateLimiterView do
  use ThingWeb, :view

  def render("rate_limiter.html", assigns) do
    ~H"""
    <div class="local-container">
      <div class="generic-error-container">
        <h1>Parece que você tentou muitas vezes! Aguarde alguns instantes e tente novamente.</h1>
      </div>
    </div>
    """
  end
end
