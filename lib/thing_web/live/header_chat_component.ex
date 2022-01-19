defmodule ThingWeb.HeaderChatComponent do
  use ThingWeb, :live_component

  def render(assigns) do
    ~H"""
    <header class="header-chat">
      <div class="header-chat-container">
        <nav class="header-chat-navbar">
          <div>
            <img
              src={Routes.static_path(@socket, "/images/menu-hamburguer.png")}
              alt="Menu hamburguer"
            />
            <div class="room-details">
              <p><%= @room_id %></p>
              <p><%= @qtd_participants %></p>
            </div>
          </div>
          <div class="header-chat-nickname">
            <p><%= @self_nickname %></p>
          </div>
        </nav>
      </div>
    </header>
    """
  end
end
