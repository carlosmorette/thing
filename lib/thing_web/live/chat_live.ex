defmodule ThingWeb.ChatLive do
  use Phoenix.LiveView

  def mount(%{"nickname" => nickname}, _session, socket) do
    IO.inspect("mount #{nickname}")
    {:ok, socket}
  end

  def mount(_params, _session, socket) do
    {:ok, push_redirect(socket, to: "/")}
  end

  def render(assigns) do
    ~H"""
    <div class="local-container">
      <h1>Chat screen</h1>
    </div>
    """
  end
end
