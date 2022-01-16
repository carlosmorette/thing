defmodule ThingWeb.HeaderComponent do
  use ThingWeb, :live_component

  def render(assigns) do
    ~H"""
    <header>
      <section>
        <a href="/">
          <img 
            src={Routes.static_path(@socket, "/images/coisa-nossa-logo.png")} 
            alt="Coisa Nossa Logo"
          />
        </a>
      </section>
    </header>
    """
  end
end
