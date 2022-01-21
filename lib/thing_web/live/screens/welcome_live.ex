defmodule ThingWeb.WelcomeLive do
  use Phoenix.LiveView

  alias Thing.Managers.SubscriberManager
  alias ThingWeb.{HeaderComponent, LoadingComponent}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok,
       assign(socket,
         page_title: "Bem Vindo",
         valid_nickname: true,
         nickname: ""
       )}
    else
      {:ok, assign(socket, page: "loading")}
    end
  end

  def render(%{page: "loading"} = assigns) do
    LoadingComponent.render(assigns)
  end

  def render(assigns) do
    ~H"""
    <%= live_component HeaderComponent, id: :header %>
      <div class="local-container">
        <section class="welcome-section">
          <h2>Bem-vindo!</h2>
          <p>O <strong>Coisa Nossa</strong> foi feito para você ter conversas seguras e temporárias, 
          ou seja, após um tempo elas sumirão e você não precisará se preocupar com seu rastro</p>
        </section>

        <%= if not((@valid_nickname)) do %>
          <small class="invalid-nickname">Coloque um nick entre 8 e 16 dígitos sem espaços</small>
        <% end %>

        <form phx-change="form" class="input-group mb-3">
          <input
            autocomplete="off"
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
    socket =
      if is_valid_id?(socket.assigns.nickname) do
        SubscriberManager.register(socket.assigns.nickname)

        socket
        |> assign(:valid_nickname, true)
        |> push_redirect(to: "/home?nickname=#{socket.assigns.nickname}")
      else
        assign(socket, :valid_nickname, false)
      end

    {:noreply, socket}
  end

  def is_valid_id?(id) do
    if not Regex.match?(~r/\s/, id) and valid_length?(id) do
      true
    else
      false
    end
  end

  def valid_length?(id), do: String.length(id) >= 8 and String.length(id) <= 16
end
