defmodule Project41.Repo.Migrations.FollowerDatabase do
  use Ecto.Migration

  def change do
    create table(:follower_database) do
      add :userid, :uuid
      add :followers, :map
  end
end
