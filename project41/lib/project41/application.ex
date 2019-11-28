defmodule Project41.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    env = Mix.env()

    if env == :dev do
      children = [
        # Starts a worker by calling: Project41.Worker.start_link(arg)
        # {Project41.Worker, arg}
        Project41.Repo,
        {Project41.LiveUserServer, %{}},
        {Project41.Demo, System.argv}
      ]

      opts = [strategy: :one_for_one, name: Project41.Supervisor]

      response = Supervisor.start_link(children, opts)

      GenServer.call(Project41.Demo, :start)

      IO.puts("Demo finished...")
      response
    else
      children = [
        # Starts a worker by calling: Project41.Worker.start_link(arg)
        # {Project41.Worker, arg}
        Project41.Repo,
        {Project41.LiveUserServer, %{}}
      ]

      opts = [strategy: :one_for_one, name: Project41.Supervisor]

      Supervisor.start_link(children, opts)
    end
  end
end
