defmodule ThingWeb.WelcomeLive do
  use Phoenix.LiveView

  alias ThingWeb.HeaderComponent

  def mount(_params, _session, socket) do
    case Cachex.get(:thing, "welcome/nickname") do
      {:ok, nil} ->
        {:ok, assign(socket, valid_input: true, nickname: "")}

      {:ok, _nickname} ->
        {:ok, push_redirect(socket, to: "/home")}
    end
  end

  def render(assigns) do
    ~H"""
    <%= live_component HeaderComponent, id: :header %>
      <div class="local-container">
        <section class="phx-hero">
          <h2>Bem-vindo!</h2>
          <p>O <strong>Coisa Nossa</strong> foi feito para você ter conversas seguras e temporárias, 
          ou seja, após um tempo elas sumirão e você não precisará se preocupar com seu rastro</p>
        </section>

        <%= if not((@valid_input)) do %>
          <small class="invalid-nickname">Coloque um nick entre 8 e 16 digitos sem espaços</small>
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
    if is_valid_id?(socket.assigns.nickname) do
      {:ok, true} = Cachex.put(:thing, "welcome/nickname", socket.assigns.nickname)

      {:noreply,
       socket
       |> assign(:valid_input, true)
       |> push_redirect(to: "/home")}
    else
      {:noreply, assign(socket, :valid_input, false)}
    end
  end

  def is_valid_id?(id) do
    if not Regex.match?(~r/\s/, id) do
      String.length(id) >= 8 and String.length(id) <= 16
    else
      false
    end
  end
end
