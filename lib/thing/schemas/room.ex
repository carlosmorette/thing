defmodule Thing.Schemas.Room do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias Thing.Schemas.Message
  alias Thing.Schemas.Room
  alias Thing.Repo

  schema "rooms" do
    field :name, :string

    has_many :messages, Message

    timestamps()
  end

  def insert(name: name) do
    insert(%{name: name})
  end

  def insert(room) do
    %Room{}
    |> change(room)
    |> Repo.insert()
  end

  def exists?(name: name) do
    query =
      from r in Room,
        where: r.name == ^name

    Repo.exists?(query)
  end

  def find(name: name) do
    query =
      from r in Room,
        where: r.name == ^name

    Repo.one(query)
  end
end
