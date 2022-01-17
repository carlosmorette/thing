defmodule ThingWeb.HeaderChatComponent do
  use ThingWeb, :live_component

  def render(assigns) do
    ~H"""
    <header class="header-chat">
      <div class="header-chat-container">
        <nav class="header-chat-navbar">
          <img
            src={Routes.static_path(@socket, "/images/menu-hamburguer.png")}
            alt="Menu hamburguer"
          />
          <div class="room-details">
            <p>MALUCOSPROGRAM</p>
            <p>5 participantes</p>
          </div>
          <div class="header-chat-nickname">
            <p>cabeçotegordo</p>
          </div>
        </nav>
      </div>
    </header>
    """
  end
end
