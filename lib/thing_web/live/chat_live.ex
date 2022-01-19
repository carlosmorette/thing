defmodule ThingWeb.ChatLive do
  use Phoenix.LiveView

  alias Thing.Managers.SubscriberManager
  alias Thing.Message
  alias Thing.Managers.ChatManager
  alias ThingWeb.HeaderChatComponent
  alias ThingWeb.BubbleMessageComponent

  def mount(%{"nickname" => nickname, "room_id" => room_id}, _session, socket) do
    ChatManager.subscribe(room_id)

    if SubscriberManager.registered?(nickname) do
      messages = ChatManager.get_all_messages(room_id)

      {:ok,
       assign(socket,
         messages: messages,
         nickname: nickname,
         room_id: room_id
       )}
    else
      {:ok, push_redirect(socket, to: "/")}
    end
  end

  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: "/")}
  end

  @spec format_messages(list(%Message{}), String.t()) :: list(map())
  defp format_messages(messages, nickname) do
    Enum.map(messages, fn m ->
      if m.nickname == nickname, do: %{m | nickname: :self}, else: m
    end)
  end

  def render(assigns) do
    ~H"""
    <%= live_component(HeaderChatComponent, 
      room_id: @room_id, 
      qtd_participants: 12,
      self_nickname: @nickname
    ) %>
    <div class="local-container">
      <%= for m <- format_messages(@messages, @nickname) do %>
        <%= live_component(BubbleMessageComponent, content: m.message, sender_name: m.nickname) %>
      <% end %>
    </div>
    """
  end

  def handle_info({:new_message, %{nickname: nickname, message: message}}, socket) do
    updated_messages = socket.assigns.messages ++ [%{nickname: nickname, message: message}]
    {:noreply, assign(socket, :messages, updated_messages)}
  end
end
