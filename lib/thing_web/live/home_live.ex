defmodule ThingWeb.HomeLive do
  use Phoenix.LiveView

  alias ThingWeb.HeaderComponent

  def mount(_params, _session, socket) do
    case Cachex.get(:thing, "welcome/nickname") do
      {:ok, nil} ->
        {:ok, push_redirect(socket, to: "/")}

      {:ok, nickname} ->
        {:ok, assign(socket, nickname: nickname, room_id: nil)}
    end
  end

  def render(assigns) do
    ~H"""
    <%= live_component HeaderComponent, id: :header %>
    <div class="local-container">
      <div class="home">
        <p class="nick"><span><%= @nickname %></span>, entre e converse!</p>
      
        <form phx-change="form" class="input-group mb-3">
          <input 
            type="text" 
            name="id"
            value={@room_id}
            class="form-control" 
            placeholder="ID da sua sala" 
          />
        </form>
        
        <div class="d-grid gap-2">
          <button phx-click="log-in" class="btn enter-button" type="button">Entrar</button>
        </div>

      </div>
    </div>
    """
  end

  def handle_event("form", %{"id" => id}, socket) do
    {:noreply, assign(socket, :room_id, id)}
  end
end
