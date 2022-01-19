defmodule ThingWeb.HomeLive do
  use Phoenix.LiveView

  alias ThingWeb.WelcomeLive
  alias Thing.Managers.SubscriberManager
  alias ThingWeb.HeaderComponent

  def mount(%{"nickname" => nickname}, _session, socket) do
    socket =
      if SubscriberManager.registered?(nickname) do
        assign(socket,
          nickname: nickname,
          room_id: "",
          valid_room_id: true
        )
      else
        push_redirect(socket, to: "/")
      end

    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: "/")}
  end

  def render(assigns) do
    ~H"""
    <%= live_component HeaderComponent, id: :header %>
    <div class="local-container">
      <div class="home">
        <p class="nick"><span><%= @nickname %></span>, entre e converse!</p>
        
        <%= if not((@valid_room_id)) do %>
          <small class="invalid-nickname">A sala deve ser entre 8 e 16 dígitos sem espaços</small>
        <% end %>

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
          <button phx-click="enter-chat" class="btn enter-button" type="button">Entrar</button>
        </div>

      </div>
    </div>
    """
  end

  def handle_event("form", %{"id" => id}, socket) do
    {:noreply, assign(socket, :room_id, id)}
  end

  def handle_event("enter-chat", _, socket) do
    room_id = socket.assigns.room_id

    socket =
      if WelcomeLive.is_valid_id?(room_id) do
        nickname = socket.assigns.nickname

        socket
        |> assign(:valid_room_id, true)
        |> push_redirect(to: "/chat?nickname=#{nickname}&room_id=#{room_id}")
      else
        assign(socket, :valid_room_id, false)
      end

    {:noreply, socket}
  end
end
