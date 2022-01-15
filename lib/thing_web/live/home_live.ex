defmodule ThingWeb.HomeLive do
  use Phoenix.LiveView

  def mount(%{"nickname" => nickname}, _session, socket) do
    {:ok, assign(socket, nickname: nickname, room_id: nil)}
  end

  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: "/")}
  end

  def render(assigns) do
    ~H"""
    <div class="local-container">
      <div class="home">
        <p class="nick"><span><%= @nickname %></span>, entre e converse!</p>
      
      <form phx-change="form" class="input-group mb-3">
        <input 
          type="text" 
          name="id"
          class="form-control" 
          placeholder="ID da sua sala" 
        />
      </form>
      
      <div class="d-grid gap-2">
        <button phx-click="log-in" class="btn btn-success" type="button">Entrar</button>
      </div>
      </div>
    </div>
    """
  end

  def handle_event("form", %{"id" => _id}, socket) do
    {:noreply, socket}
  end
end
