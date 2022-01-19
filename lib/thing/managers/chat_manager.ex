defmodule Thing.Managers.ChatManager do
  use GenServer

  alias Thing.Message

  @impl true
  def init(_stack), do: {:ok, []}

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def handle_call({:new_message, nickname, message, room_id}, _from, state) do
    {:reply, :ok, state ++ [%Message{nickname: nickname, message: message, room_id: room_id}]}
  end

  @impl true
  def handle_call({:get_messages, room_id}, _from, state) do
    room_messages = Enum.filter(state, fn m -> m.room_id == room_id end)
    {:reply, room_messages, state}
  end

  def get_all_messages(room_id) do
    GenServer.call(__MODULE__, {:get_messages, room_id})
  end

  def add_message(nickname: nickname, message: message, room_id: room_id) do
    :ok = GenServer.call(__MODULE__, {:new_message, nickname, message, room_id})

    Phoenix.PubSub.broadcast(
      Thing.PubSub,
      "room:#{room_id}",
      {:new_message, %{nickname: nickname, message: message}}
    )
  end

  def subscribe(room_id) do
    IO.inspect(room_id, label: "===ROOM_ID===")
    Phoenix.PubSub.subscribe(Thing.PubSub, "room:" <> room_id)
  end
end
