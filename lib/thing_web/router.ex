defmodule ThingWeb.Router do
  use ThingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ThingWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ThingWeb do
    pipe_through :browser

    get "/", HomeController, :index
    live "/home", HomeLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", ThingWeb do
  #   pipe_through :api
  # end
end
