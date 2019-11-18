defmodule Project41.Userdata do
  use Ecto.Schema
  #
  # Schema for when a new user is registered.
  # When a user tries to register, it will check if it is already existing for a given username
  # if the given username already exists in user_database, then if ("username", "password") tuple
  # is correct, then login occurs instead, otherwise, you insert into the user_database
  # primary key has to be auto-incremented
  #
  @primary_key {:userid, :binary_id, autogenerate: true}
  # @derive {Pheonix.Param, key: :userid}
  schema "user_database" do
    field :username, :string
    field :password, :string
    field :name, :string
    field :tweets, {:array, :string}
    field :mentions, {:array, :string}
    field :followers, {:array, :binary_id}
    field :feed, {:array, :string}
  end
  #
  # In the perfect world, the userdata and tweets should be held on different databases. However,
  # I did not want to design a complicated schema so this rather inefficient model would have to be
  #
  #
end
