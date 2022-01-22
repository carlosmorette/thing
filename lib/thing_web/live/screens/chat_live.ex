defmodule ThingWeb.ChatLive do
  use Phoenix.LiveView

  alias Thing.Managers.SubscriberManager
  alias Thing.Message
  alias Thing.Managers.ChatManager
  # alias Thing.Schemas.Room
  alias ThingWeb.{HeaderChatComponent, BubbleMessageComponent, LoadingComponent}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok,
       socket
       |> assign(page_title: "", messages: [], nickname: "", room_id: "", input_value: "")
       |> push_event("joined-chat", %{})}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  @spec format_messages(list(%Message{}), String.t()) :: list(map())
  defp format_messages(messages, nickname) do
    Enum.map(messages, fn m ->
      if m.nickname == nickname, do: %{m | nickname: :self}, else: m
    end)
  end

  def render(%{page: "loading"} = assigns) do
    LoadingComponent.render(assigns)
  end

  def render(assigns) do
    ~H"""
    <%= live_component(HeaderChatComponent, 
      room_id: @room_id, 
      qtd_participants: 12,
      self_nickname: @nickname
    ) %>

    <div class="chat-container" phx-hook="ChatLive" id="chat-container">
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
        autocomplete="false"
        id="btn-send-message"
        class="btn send-button" 
        type="button">Enviar</button>
    </div>
    """
  end

  def handle_event("form", %{"input" => value}, socket) do
    {:noreply, assign(socket, :input_value, value)}
  end

  def handle_event("send", _params, socket) do
    %{nickname: nickname, room_id: room_id, input_value: input_value} = socket.assigns

    unless input_value == "" do
      ChatManager.add_message(nickname: nickname, message: input_value, room_id: room_id)
    end

    {:noreply, assign(socket, :input_value, "")}
  end

  def handle_event("mounted", %{"nickname" => nickname, "room_id" => room_id}, socket) do
    ChatManager.subscribe(room_id)

    socket =
      if SubscriberManager.registered?(nickname) do
        assign(socket,
          nickname: nickname,
          messages: ChatManager.get_all_messages(room_id),
          room_id: room_id,
          page_title: room_id
        )
      else
        push_redirect(socket, to: "/")
      end

    {:noreply, socket}
  end

  def handle_info({:new_message, %{nickname: nickname, message: message}}, socket) do
    updated_messages = socket.assigns.messages ++ [%{nickname: nickname, message: message}]

    {:noreply,
     socket
     |> assign(:messages, updated_messages)
     |> push_event("new-message", %{})}
  end
end
