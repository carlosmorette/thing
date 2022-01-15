defmodule ThingWeb.HomeLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, valid_input: true, username: "")}
  end

  def render(assigns) do
    ~H"""
      <main class="local-container">
        <section class="phx-hero">
          <h2>Bem-vindo!</h2>
          <p>O <strong>Coisa Nossa</strong> foi feito para você ter conversas seguras e temporárias, 
          ou seja, após um tempo elas sumirão e você não precisará se preocupar com seu rastro</p>
        </section>

        <%= if not((@valid_input)) do %>
          <small class="invalid-username">Coloque um nome entre 8 e 16 digitos</small>
        <% end %>

        <form phx-change="username-form" class="input-group mb-3">
          <input 
            type="text" 
            value={@username}
            name="input"
            class="form-control" 
            placeholder="Nickname" 
          />
        </form>

        <div class="d-grid gap-2">
          <button phx-click="log-in" class="sign-in-button btn" type="button">Acessar</button>
        </div>
      </main>
    """
  end

  def handle_event("username-form", %{"input" => value}, socket) do
    {:noreply, assign(socket, :username, value)}
  end

  def handle_event("log-in", _params, socket) do
    if valid_username?(socket.assigns.username) do
      {:noreply,
       socket
       |> assign(:valid_input, true)
       |> push_redirect(to: "/chat")}
    else
      {:noreply, assign(socket, :valid_input, false)}
    end
  end

  def valid_username?(username) do
    String.length(username) >= 8 and String.length(username) <= 16
  end
end
