defmodule ThingWeb.ExceededLimitComponent do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="local-container">
      <div class="generic-error-container">
        <h1>Parece que você tentou muitas vezes! Aguarde alguns instantes e tente novamente.</h1>
      </div>
    </div>
    """
  end
end
