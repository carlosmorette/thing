defmodule Thing.SubscriberManager do
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def registered?(nickname) do
    Agent.get(__MODULE__, fn users -> nickname in users end)
  end

  def register(nickname) do
    Agent.update(__MODULE__, fn users -> [nickname | users] end)
  end

  def remove(nickname) do
    Agent.update(__MODULE__, &Enum.reject(&1, fn u -> u == nickname end))
  end

  def remove_all() do
    Agent.update(__MODULE__, fn _ -> [] end)
  end

  if Mix.env() == :dev do
    def get_all(), do: Agent.get(__MODULE__, fn users -> users end)
  end
end
