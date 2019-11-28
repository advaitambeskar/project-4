defmodule Project41.Client do
  import Ecto.Query

  def main() do
    Project41.ClientFunctions.register("msa", "msa")
    Project41.ClientFunctions.logout("msa")
    Project41.ClientFunctions.login("msa", "msa")
    Project41.ClientFunctions.logout("msa")
    Project41.ClientFunctions.delete("msa", "msa")
    Project41.ClientFunctions.logout("msa")
    Project41.ClientFunctions.login("advaitambeskar", "advait")
    Project41.ClientFunctions.login("msa", "msa")
    Project41.ClientFunctions.delete("msa", "msa")
    :end
  end
end


defmodule Project41.ClientFunctions do
  import Ecto.Query
  @moduledoc """
  Create Endpoints of sorts for client functions so that they can be directly used.
  Improved interface
  """
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
    IO.inspect Project41.TweetEngine.subscribe_to_user(subscriber, username)
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
