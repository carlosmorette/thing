defmodule ThingWeb.LoadingComponent do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div class="local-container">
      <div class="generic-error-container">
        <h1>Carregando...</h1>
      </div>
    </div>
    """
  end
end
