defmodule ThingWeb.ChatLive do
  use Phoenix.LiveView

  alias Thing.SubscriberManager
  # alias Thing.Managers.ChatManager
  alias Thing.Schemas.{Room, Message}
  alias ThingWeb.{HeaderChatComponent, BubbleMessageComponent, LoadingComponent}

  @type individual_message :: %{sender_name: String.t(), content: String.t()}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok,
       socket
       |> assign(
         page_title: "",
         messages: [],
         nickname: "",
         room_name: "",
         input_value: ""
       )
       |> push_event("joined-chat", %{})}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  @spec format_messages(list(individual_message()), String.t()) :: any()
  defp format_messages(messages, nickname) do
    Enum.map(messages, fn m ->
      if m.sender_name == nickname do
        %{content: m.content, nickname: :self}
      else
        %{content: m.content, nickname: m.sender_name}
      end
    end)
  end

  def render(%{page: "loading"} = assigns) do
    LoadingComponent.render(assigns)
  end

  def render(assigns) do
    ~H"""
    <%= live_component(HeaderChatComponent, 
      room_name: @room_name, 
      self_nickname: @nickname
    ) %>

    <div class="chat-container" phx-hook="ChatLive" id="chat-container">
      <%= for m <- format_messages(@messages, @nickname) do %>
        <%= live_component(BubbleMessageComponent, content: m.content, sender_name: m.nickname) %>
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
        phx-click="send-new-message" 
        autocomplete="false"
        id="btn-send-message"
        class="btn send-button" 
        type="button">Enviar</button>
    </div>
    """
  end

  def handle_event(
        "hook:chat-live:mounted",
        %{"nickname" => nickname, "room_name" => room_name} = _params,
        socket
      ) do
    Message.subscribe(room_name)

    socket =
      if SubscriberManager.registered?(nickname) and Room.exists?(name: room_name) do
        assign(socket,
          nickname: nickname,
          messages: Message.get_all_messages_by_room_name(room_name),
          room_name: room_name,
          page_title: room_name
        )
      else
        push_redirect(socket, to: "/")
      end

    {:noreply, socket}
  end

  def handle_event("form", %{"input" => value}, socket) do
    {:noreply, assign(socket, :input_value, value)}
  end

  def handle_event("send-new-message", _params, socket) do
    %{nickname: nickname, room_name: room_name, input_value: input_value} = socket.assigns

    unless input_value == "" do
      Message.add_message(message: input_value, nickname: nickname, room_name: room_name)
    end

    {:noreply, assign(socket, :input_value, "")}
  end

  def handle_info({:new_message, %{nickname: nickname, message: message}}, socket) do
    updated_messages = socket.assigns.messages ++ [%{sender_name: nickname, content: message}]

    {:noreply,
     socket
     |> assign(:messages, updated_messages)
     |> push_event("new-message", %{})}
  end
end
