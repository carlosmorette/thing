defmodule ThingWeb.BubbleMessageComponent do
  use ThingWeb, :live_component

  def mount(socket) do
    {:ok, socket}
  end

  def render(%{message: _message, sender_name: :self} = assigns) do
    ~H"""
    <div class="bubble-container right-align">
      <div class="bubble-message self-bubble">
        <p><%= @message %></p>
      </div>
    </div>
    """
  end

  def render(%{message: _message, sender_name: _sender_name} = assigns) do
    ~H"""
    <div class="bubble-container left-align">
      <div class="bubble-message participant-bubble">
        <p class="bubble-sender-name"><%= @sender_name %></p>
        <%= @message %>
      </div>
    </div>
    """
  end

  def render(assigns) do
    ~H"""
      <div></div>
    """
  end
end
