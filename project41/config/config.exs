import Config

config :project41, Project41.Repo,
  database: "project41_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5433
config :project41, ecto_repos: [Project41.Repo]
config :logger, level: :info
