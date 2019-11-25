defmodule Project41.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Project41.Worker.start_link(arg)
      # {Project41.Worker, arg}
      Project41.Repo,
    ]
    {response, server_process_id} = Project41.LiveUserServer.start_link()
#   Project41.LiveUserServer.userLogedIn(self(),456)
    IO.inspect server_process_id
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Project41.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
