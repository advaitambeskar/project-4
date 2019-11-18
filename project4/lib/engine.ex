defmodule TweetEngine do
  use GenServer
  # Register Account
  # Login
  # Send Tweet
  #
  # Create central list with userid, name, passwords?
  def init(userid, name, islogin, tweets, mentions, followers, followingUsers, followingHashtag) do
    state = [userid, name, islogin, tweets, mentions, followers, followingUsers, followingHashtag]
    {:ok, state}
  end

  def registerAccount(username, password, name) do
    state = []
    currentuser = [username, password]
    if(!(state == currentuser)) do
      # create a new process with
      # username = userid, password = password, isLogin = false, tweets = [], mentions = []
      # followers = [], followingUsers = [], followingHashtag = []
    else do
      # return a message that says that the account has already been registered.
    end
  end

  def login(username, password) do
    currentstate = [username, password]
    # If the currentstate is present in the central list then send message that login successful
    # Else if the currentstate is not present in the central list then login is not successful
  end

  def sendTweet(name, ) do

  end
end
