defmodule Thing.Repo.Migrations.AddMessagesAndRoomsTable do
  use Ecto.Migration

  def change do
    create table("rooms") do
      add :name, :string

      timestamps()
    end

    create table("messages") do
      add :content, :string
      add :sender_name, :string
      add :room_id, references(:rooms)

      timestamps()
    end
  end
end
