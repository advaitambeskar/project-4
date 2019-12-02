
defmodule Project41.ClientFunctions do
  import Ecto.Query
  @moduledoc """
  This is the Project41.ClientFunctions module. The purpose of this module is to provide end points for the front-end to communicate with the server.
  The module accumalates functions that enable the connected client-user to communicate and produce logical changes to the state of itself and the
  client-users connected.
  """
  @moduledoc since: "1.0.0"

  @doc """
  Allows a new client-user to register into the system.
  Accepts a username and password combination with the pre-condition that the username does not
  already exist in the database. Saves the combination in the database so that the user can login
  anytime.
  If successful login occurs, the username and password combination attempts to login
  If the user already exists, then the username and password combination attempts to login

  Returns `:ok`

  ## Examples
    iex> Project41.ClientFunctions.register("advait", "pwd")
    :ok
  """
  @doc since: "1.0.0"
  def register(username, password) do
    {reply} = Project41.LoginEngine.registerUser(username, password)
    cond do
      reply == :newUser ->
        IO.inspect "Successfully registered #{username} as a new user."
        Project41.ClientFunctions.login(username, password)
      reply == :oldUser ->
        IO.inspect "User #{username} is an old user. Attempting login instead."
        Project41.ClientFunctions.login(username, password)
    end
    :ok
  end

  def login(username, password) do
    {login_reply, useriden} = Project41.LoginEngine.login(username, password)
    #IO.inspect userid
    cond do
      login_reply == :loginSuccessful ->
        [userid] = useriden
        tweets = []

        [followers] = from(user in Project41.Follower, select: user.followers, where: user.userid==^userid) |> Project41.Repo.all

        [feed] = from(user in Project41.Feed, select: user.tweets, where: user.userid==^userid) |> Project41.Repo.all

        {pid, client_state} = Project41.TweetEngine.start(userid, tweets, followers, feed)
        Project41.LiveUserServer.userLogedIn(userid, pid)

        "Login as #{username} was successful"
      login_reply == :loginUnsucessful ->
        "Sorry, the attempt to login to #{useriden} was unsuccessful"
      login_reply == :duplicateLogin ->
        "Previous sign in detected. You are already logged in as #{useriden}."
      true ->
        IO.inspect "Unexpected error during output. Please check the logs."
    end
  end

  def logout(username) do
    IO.inspect Project41.LoginEngine.logout(username)
  end

  def delete(username, password) do
    IO.inspect Project41.LoginEngine.deleteUser(username, password)
  end

  def subscribeToUser(subscriber, username) do
    IO.puts Project41.TweetEngine.subscribe_to_user(subscriber, username)
  end

  def tweet(user, tweet) do
    Project41.TweetFacility.sendTweet(user, tweet)
  end

  def retweet(user, tweetid) do
    Project41.TweetFacility.reTweet(user, tweetid)
  end

  # mentions and hashtag querying and user querying can occur only if the user is logged in. Login check
  # is needed to be done/ performed
end
