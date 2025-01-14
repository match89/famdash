defmodule Famdash.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FamdashWeb.Telemetry,
      Famdash.Repo,
      {DNSCluster, query: Application.get_env(:famdash, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Famdash.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Famdash.Finch},
      # Start a worker by calling: Famdash.Worker.start_link(arg)
      # {Famdash.Worker, arg},
      # Start to serve requests, typically the last entry
      FamdashWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Famdash.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FamdashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
