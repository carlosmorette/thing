defmodule Thing.Managers.ChatManager do
  use GenServer

  alias Thing.Message

  @impl true
  def init(_stack), do: {:ok, []}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def handle_call({:new_message, nickname, message}, _from, state) do
    {:reply, :ok, state ++ [%Message{nickname: nickname, message: message}]}
  end

  @impl true
  def handle_call(:get_messages, _from, state) do
    {:reply, state, state}
  end

  def get_all_messages() do
    GenServer.call(__MODULE__, :get_messages)
  end

  def save_message(nickname: nickname, message: message, room_id: room_id) do
    :ok = GenServer.call(__MODULE__, {:new_message, nickname, message})

    Phoenix.PubSub.broadcast(
      Thing.PubSub,
      "room:#{room_id}",
      {:new_message, %{nickname: nickname, message: message}}
    )
  end

  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(Thing.PubSub, "room:" <> room_id)
  end

  # TODO: implementar apagar mensagem
end
