defmodule ThingWeb.HomeLive do
  use Phoenix.LiveView

  alias ThingWeb.WelcomeLive
  alias Thing.SubscriberManager
  alias ThingWeb.{HeaderComponent, LoadingComponent}
  alias Thing.Schemas.Room

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok,
       assign(socket,
         page_title: "Home",
         room_name: "",
         nickname: "",
         valid_room_name: true
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
        
        <%= if not((@valid_room_name)) do %>
          <small class="invalid-nickname">A sala deve ser entre 8 e 16 dígitos sem espaços</small>
        <% end %>

        <form phx-change="form" class="input-group mb-3">
          <input 
            autocomplete="off"
            type="text"
            name="room_name"
            value={@room_name}
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

  def handle_event("hook:home-live:mounted", %{"nickname" => nickname}, socket) do
    socket =
      if SubscriberManager.registered?(nickname) do
        assign(socket, :nickname, nickname)
      else
        push_redirect(socket, to: "/")
      end

    {:noreply, socket}
  end

  def handle_event("hook:home-live:created-room", %{"room_name" => _room}, socket) do
    {:noreply,
     socket
     |> assign(:valid_room_name, true)
     |> push_redirect(to: "/chat")}
  end

  def handle_event("form", %{"room_name" => room_name}, socket) do
    {:noreply, assign(socket, :room_name, room_name)}
  end

  def handle_event("enter-chat", _params, socket) do
    room_name = socket.assigns.room_name

    socket =
      case is_valid_name?(room_name) do
        :ok ->
          create_if_not_exist(room_name)
          push_event(socket, "new-room", %{room_name: room_name})

        {:error, :invalid} ->
          assign(socket, :valid_room_name, false)
      end

    {:noreply, socket}
  end

  def is_valid_name?(room_name) do
    with :ok <- WelcomeLive.has_not_space?(room_name),
         :ok <- WelcomeLive.valid_length?(room_name) do
      :ok
    else
      {:error, _error} -> {:error, :invalid}
    end
  end

  def create_if_not_exist(room_name) do
    unless Room.exists?(name: room_name) do
      Room.insert(name: room_name)
    end
  end
end
