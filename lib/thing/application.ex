defmodule Thing.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Thing.Repo,
      # Start the Telemetry supervisor
      ThingWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Thing.PubSub},
      # Start the Endpoint (http/https)
      ThingWeb.Endpoint,
      # Message store
      # Thing.Managers.ChatManager,

      # Cron job
      Thing.Scheduler,

      # Subscriber Store
      Thing.SubscriberManager
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Thing.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ThingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
