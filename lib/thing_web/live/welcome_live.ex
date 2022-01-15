defmodule ThingWeb.WelcomeLive do
  use Phoenix.LiveView

  def mount(_params, _session, socket) do
    {:ok, assign(socket, valid_input: true, nickname: "")}
  end

  def render(assigns) do
    ~H"""
      <div class="local-container">
        <section class="phx-hero">
          <h2>Bem-vindo!</h2>
          <p>O <strong>Coisa Nossa</strong> foi feito para você ter conversas seguras e temporárias, 
          ou seja, após um tempo elas sumirão e você não precisará se preocupar com seu rastro</p>
        </section>

        <%= if not((@valid_input)) do %>
          <small class="invalid-nickname">Coloque um nick entre 8 e 16 digitos</small>
        <% end %>

        <form phx-change="form" class="input-group mb-3">
          <input 
            type="text" 
            value={@nickname}
            name="input"
            class="form-control" 
            placeholder="Nickname" 
          />
        </form>

        <div class="d-grid gap-2">
          <button phx-click="log-in" class="sign-in-button btn" type="button">Acessar</button>
        </div>
      </div>
    """
  end

  def handle_event("form", %{"input" => value}, socket) do
    {:noreply, assign(socket, :nickname, value)}
  end

  def handle_event("log-in", _params, socket) do
    if valid_nickname?(socket.assigns.nickname) do
      {:noreply,
       socket
       |> assign(:valid_input, true)
       |> push_redirect(to: "/home?nickname=#{socket.assigns.nickname}")}
    else
      {:noreply, assign(socket, :valid_input, false)}
    end
  end

  def valid_nickname?(nick) do
    String.length(nick) >= 8 and String.length(nick) <= 16
  end
end
