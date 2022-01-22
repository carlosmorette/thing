defmodule ThingWeb.HomeLive do
  use Phoenix.LiveView

  alias ThingWeb.WelcomeLive
  alias Thing.Managers.SubscriberManager
  alias ThingWeb.{HeaderComponent, LoadingComponent}
  # alias Thing.Schemas.Room

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok,
       assign(socket,
         page_title: "Home",
         room_id: "",
         nickname: "",
         valid_room_id: true
       )}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  def render(%{page: "loading"} = assigns) do
    LoadingComponent.render(assigns)
  end

  def render(assigns) do
    ~H"""
    <%= live_component HeaderComponent, id: :header %>
    <div class="local-container" phx-hook="HomeLive" id="home-container">
      <div class="home">
        <p class="nick"><span><%= @nickname %></span>, entre e converse!</p>
        
        <%= if not((@valid_room_id)) do %>
          <small class="invalid-nickname">A sala deve ser entre 8 e 16 dígitos sem espaços</small>
        <% end %>

        <form phx-change="form" class="input-group mb-3">
          <input 
            autocomplete="off"
            type="text"
            name="id"
            value={@room_id}
            class="form-control" 
            placeholder="ID da sua sala" 
          />
        </form>
        
        <div class="d-grid gap-2">
          <button phx-click="enter-chat" class="btn enter-button" type="button">Entrar</button>
        </div>

      </div>
    </div>
    """
  end

  def handle_event("mounted", %{"nickname" => nickname}, socket) do
    socket =
      if SubscriberManager.registered?(nickname) do
        assign(socket, :nickname, nickname)
      else
        push_redirect(socket, to: "/")
      end

    {:noreply, socket}
  end

  def handle_event("created-room", %{"room_id" => _room}, socket) do
    {:noreply,
     socket
     |> assign(:valid_room_id, true)
     |> push_redirect(to: "/chat")}
  end

  def handle_event("form", %{"id" => id}, socket) do
    {:noreply, assign(socket, :room_id, id)}
  end

  def handle_event("enter-chat", _, socket) do
    room_id = socket.assigns.room_id

    socket =
      if WelcomeLive.is_valid_id?(room_id) do
        # Room.insert(name: room_id)
        push_event(socket, "new-room", %{room_id: room_id})
      else
        assign(socket, :valid_room_id, false)
      end

    {:noreply, socket}
  end
end
