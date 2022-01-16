defmodule ThingWeb.ChatLive do
  use Phoenix.LiveView

  alias ThingWeb.HeaderChatComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= live_component HeaderChatComponent, id: :header_chat %>
    <div class="local-container">
      <h1>Chat screen</h1>
    </div>
    """
  end
end
