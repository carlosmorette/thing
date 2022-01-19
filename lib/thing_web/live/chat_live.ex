defmodule ThingWeb.ChatLive do
  use Phoenix.LiveView

  alias Thing.Managers.SubscriberManager
  alias Thing.Managers.ChatManager
  alias ThingWeb.HeaderChatComponent
  alias ThingWeb.BubbleMessageComponent

  def mount(%{"nickname" => nickname, "room_id" => room_id}, _session, socket) do
    IO.inspect({nickname, room_id}, label: "PARAMS")

    if SubscriberManager.registered?(nickname) do
      messages = ChatManager.get_all_messages()
      {:ok, assign(socket, messages: messages, nickname: nickname)}
    else
      {:ok, push_redirect(socket, to: "/")}
    end
  end

  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: "/")}
  end

  def render(assigns) do
    ~H"""
    <%= live_component HeaderChatComponent %>
    <div class="local-container">

      <%= live_component BubbleMessageComponent, message: "Lorem ipsum \
      varius ultricies adipiscing 
      elit justo tortor torquent imperdie blandit. ", sender_name: :self %>
      <%= live_component BubbleMessageComponent, message: "Lorem ipsum varius ultricies adipiscing elit justo tortor torquent", sender_name: "littlelorem" %>
    </div>
    """
  end

  def handle_info({:new_message, %{nickname: nickname, message: message}}, socket) do
    IO.inspect(%{nickname: nickname, message: message}, label: "===nova_mensagem===")
    {:noreply, socket}
  end
end
