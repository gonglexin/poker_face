defmodule PokerFace.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PokerFaceWeb.Telemetry,
      PokerFace.Repo,
      {DNSCluster, query: Application.get_env(:poker_face, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PokerFace.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PokerFace.Finch},
      # Start a worker by calling: PokerFace.Worker.start_link(arg)
      # {PokerFace.Worker, arg},
      # Start to serve requests, typically the last entry
      PokerFaceWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PokerFace.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PokerFaceWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
