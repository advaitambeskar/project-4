defmodule Project41.MixProject do
  use Mix.Project

  def project do
    [
      app: :project41,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Project4",
      source_url: "https://github.com/advaitambeskar/project-4",
      homepage_url: "https://github.com/advaitambeskar/project-4",
      # docs: [
      #   main: "Project41.Proj4",
      #   extras: ["README.md"]
      # ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      Application.start(Project41.Proj4),
      extra_applications: [:logger],
      mod: {Project41.Proj4, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:elixir_uuid, "~> 1.2"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
