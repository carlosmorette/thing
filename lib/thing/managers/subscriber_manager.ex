defmodule Thing.Managers.SubscriberManager do
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

  if Mix.env() == :dev do
    def get_all(), do: Agent.get(__MODULE__, fn users -> users end)
  end
end
