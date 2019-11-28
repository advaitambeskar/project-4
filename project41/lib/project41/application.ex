defmodule Project41.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Project41.Worker.start_link(arg)
      # {Project41.Worker, arg}

#      {Project41.Demo, System.argv}
    ]

    Project41.Repo.start_link()
    Project41.LiveUserServer.start_link()

    start_program(System.argv)

    opts = [strategy: :one_for_one, name: Project41.Supervisor]

    Supervisor.start_link(children, opts)

    receiver()
  end

  def receiver() do
    receiver()
  end
  def start_program(args) do
      cond do
        length(args) == 2->
          [numberOfUsers, numberOfTweets] = args
          users = String.to_integer(numberOfUsers)
          tweets = String.to_integer(numberOfTweets)

          Project41.Demo.initiate(users, tweets)
        true ->
          IO.puts("The number of arguments is invalid")
          System.halt(0)
      end
  end
end
