defmodule Thing.Schemas.Message do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Thing.Schemas.Message
  alias Thing.Schemas.Room
  alias Thing.Repo

  schema "messages" do
    field :content, :string
    field :sender_name, :string

    belongs_to :room, Room

    timestamps()
  end

  def changeset(message, attrs) do
    message
    |> cast(attrs, [:content, :sender_name, :room_id])
    |> validate_required([:content, :sender_name, :room_id])
  end

  def subscribe(room_id) do
    Phoenix.PubSub.subscribe(Thing.PubSub, "room:" <> room_id)
  end

  def add_message(message: message, nickname: nickname, room_name: room_name) do
    room = Room.find(name: room_name)

    insert(%{
      content: message,
      sender_name: nickname,
      room_id: room.id
    })

    Phoenix.PubSub.broadcast(
      Thing.PubSub,
      "room:" <> room_name,
      {:new_message, %{nickname: nickname, message: message}}
    )
  end

  def insert(message) do
    %Message{}
    |> changeset(message)
    |> Repo.insert()
  end

  def get_all_messages_by_room_name(room_name) do
    query =
      from m in Message,
        join: r in Room,
        on: m.room_id == r.id,
        where: r.name == ^room_name

    Repo.all(query)
  end
end
