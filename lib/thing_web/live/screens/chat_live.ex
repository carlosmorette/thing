defmodule ThingWeb.ChatLive do
  use Phoenix.LiveView

  alias Thing.Managers.SubscriberManager
  alias Thing.Message
  alias Thing.Managers.ChatManager
  alias ThingWeb.{HeaderChatComponent, BubbleMessageComponent}

  def mount(%{"nickname" => nickname, "room_id" => room_id}, _session, socket) do
    ChatManager.subscribe(room_id)

    socket =
      if SubscriberManager.registered?(nickname) do
        assign(socket,
          messages: ChatManager.get_all_messages(room_id),
          nickname: nickname,
          room_id: room_id,
          input_value: ""
        )
        |> push_event("into-chat", %{})
      else
        push_redirect(socket, to: "/")
      end

    {:ok, socket}
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

    <div class="chat-container">
      <%= for m <- format_messages(@messages, @nickname) do %>
        <%= live_component(BubbleMessageComponent, content: m.message, sender_name: m.nickname) %>
      <% end %>
    </div>

    <div class="input-container">
      <div>
        <form phx-change="form" autocomplete="off">
          <input
            type="text"
            value={@input_value}
            name="input"
            class="form-control"
            placeholder="Diga algo..."
          />
        </form>
      </div>
      <button 
        phx-click="send" 
        phx-hook="Button"
        autocomplete="false"
        id="btn-send-message"
        class="btn send-button" 
        type="button">Enviar</button>
    </div>
    """
  end

  def handle_info({:new_message, %{nickname: nickname, message: message}}, socket) do
    updated_messages = socket.assigns.messages ++ [%{nickname: nickname, message: message}]

    {:noreply,
     socket
     |> assign(:messages, updated_messages)
     |> push_event("new-message", %{})}
  end

  def handle_event("send", _params, socket) do
    %{nickname: nickname, room_id: room_id, input_value: input_value} = socket.assigns

    unless input_value == "" do
      ChatManager.add_message(nickname: nickname, message: input_value, room_id: room_id)
    end

    {:noreply, assign(socket, :input_value, "")}
  end

  def handle_event("form", %{"input" => value}, socket) do
    {:noreply, assign(socket, :input_value, value)}
  end
end
