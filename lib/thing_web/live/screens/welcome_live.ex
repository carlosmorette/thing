defmodule ThingWeb.WelcomeLive do
  use Phoenix.LiveView

  alias Thing.SubscriberManager
  alias ThingWeb.{HeaderComponent, LoadingComponent}

  def mount(_params, _session, socket) do
    if connected?(socket) do
      {:ok,
       assign(socket,
         page_title: "Bem Vindo - Coisa Nossa",
         valid_nickname: true,
         unavailable_nickname: false,
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
          ou seja, no final do dia elas sumirão e você não precisará se preocupar com seu rastro</p>
        </section>

        <%= if not((@valid_nickname)) do %>
          <small class="invalid-nickname">Coloque um nick entre 8 e 16 dígitos sem espaços</small>
        <% end %>

        <%= if (@unavailable_nickname) do %>
          <small class="invalid-nickname">Nickname indisponível no momento</small>
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
          <button 
            phx-hook="SignUpButton" 
            phx-click="phx-click:button:log-in" 
            id="btn-sign-up"
            class="sign-up-button btn" 
            type="button">Acessar</button>
        </div>
      </div>
    """
  end

  def handle_event("hook:signup-button:registered", %{"nickname" => _nickname}, socket) do
    {:noreply,
     socket
     |> assign(:valid_nickname, true)
     |> push_redirect(to: "/home")}
  end

  def handle_event("form", %{"input" => value}, socket) do
    {:noreply, assign(socket, :nickname, value)}
  end

  def handle_event("phx-click:button:log-in", _params, socket) do
    nickname = socket.assigns.nickname

    socket =
      with :ok <- has_not_space?(nickname),
           :ok <- valid_length?(nickname),
           :ok <- nickname_is_available?(nickname) do
        SubscriberManager.register(nickname)
        push_event(socket, "new-subscriber", %{nickname: nickname})
      else
        {:error, :unavailable} -> assign(socket, :unavailable_nickname, true)
        {:error, _error} -> assign(socket, :valid_nickname, false)
      end

    {:noreply, socket}
  end

  def has_not_space?(nickname) do
    if not Regex.match?(~r/\s/, nickname) do
      :ok
    else
      {:error, :has_space}
    end
  end

  def valid_length?(id) do
    if String.length(id) >= 8 and String.length(id) <= 16 do
      :ok
    else
      {:error, :invalid_length}
    end
  end

  def nickname_is_available?(nickname) do
    if not SubscriberManager.registered?(nickname) do
      :ok
    else
      {:error, :unavailable}
    end
  end
end
