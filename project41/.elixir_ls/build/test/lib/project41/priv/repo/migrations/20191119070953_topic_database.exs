defmodule Project41.Repo.Migrations.TopicDatabase do
  use Ecto.Migration

  def change do
    create table(:topic_database, primary_key: false) do
      add :hashid, :uuid, primary_key: true
      add :hashtags, :string
      add :subscribers, {:array, :binary_id}, default: []
      add :tweetids, {:array, :binary_id}, default: []
    end
  end
end
