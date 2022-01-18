defmodule ThingWeb.ChatLive do
  use Phoenix.LiveView

  alias ThingWeb.HeaderChatComponent
  alias ThingWeb.BubbleMessageComponent

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <%= live_component HeaderChatComponent %>
    <div class="local-container">
      <%= live_component BubbleMessageComponent, message: "Lorem ipsum \
      varius ultricies adipiscing 
      elit justo tortor torquent imperdiet lectus vehicula fames, cursus nulla tellus congue in torquent ut augue neque proin blandit. ", sender_name: :self %>
      <%= live_component BubbleMessageComponent, message: "Lorem ipsum varius ultricies adipiscing elit justo tortor torquent", sender_name: "littlelorem" %>
    </div>
    """
  end
end
