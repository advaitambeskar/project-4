
defmodule Project41.TweetEngine do
  use GenServer
  # Each username is associated with its corresponding userID, which becomes the foreign keys for the rest of the
  # stuff
  # When login occurs, a new process is created and the userid is associated with that login. Each process maintains a 'cookie' of sorts
  # that allows the user to log-off
  def init(init_arg) do
    {:ok, init_arg}
  end

  def init(userid, tweets, followers, feed) do
    {:ok, {userid, tweets, followers, feed}}
  end

  def start(userid, tweets, followers, feed) do
    state = {userid, tweets, followers, feed}
    {:ok, pid} = GenServer.start(__MODULE__, state)
    {pid, state}
  end

  def get_state(pid) do
    GenServer.call(pid, :getState)
  end

# username and subscriber need to be valid username
# subscriber needs to be logged in
# user and subscriber cant be null or empty strings
# User cannot follow self
# User cannot re subscribe someone
  def subscribe_to_user(subscriber, username) do
    if (Project41.LoginEngine.isUserNameValid(username) == false or username == nil or username == "") do
      IO.puts "the user you are trying to subscribe doesn't exist"
    else
      if (Project41.LoginEngine.isUserNameValid(subscriber) == false or Project41.LoginEngine.isLogin?(subscriber) == false or username == nil or username == "") do
        IO.puts "Please login first"
      else
        userID = Project41.TweetFacility.getUserIDFromName(username)
        liveUserMap =  Project41.LiveUserServer.get_state()
        pid = Map.get(liveUserMap, userID)
       {id, tweets, followers, feed} = :sys.get_state(pid)
       if ( Enum.member?(followers, Project41.TweetFacility.getUserIDFromName(subscriber)) )do
         IO.puts "Already following"
         else
           if(username == subscriber) do
             IO.puts "cannot follow self"
             else
             userID = Project41.TweetFacility.getUserIDFromName(username)
             subscriberId = Project41.TweetFacility.getUserIDFromName(subscriber)
             liveUserMap =  Project41.LiveUserServer.get_state()

             userProcessId = Map.get(liveUserMap, userID)

             updateFollower(userProcessId, subscriberId)
           end
       end
      end
    end
  end

  def addTweet(pid, tweet) do
    GenServer.call(pid, {:addTweet, tweet})
  end

  def updateFeed(pid, tweet) do
    GenServer.call(pid, {:updateFeed, tweet})
  end

  def updateFollower(pid, follower) do
    GenServer.call(pid, {:updateFollower, follower})
  end

  def getFollowers(pid) do
    {_userid, _tweets, followers, _feed} = get_state(pid)
    followers
  end

  # Handle calls and casts for the engine
  def handle_call(:getState, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:addTweet, tweet}, _from, state) do
    {userid, tweets, followers, feed} = state

    updatedTweets = tweets ++ [tweet]
    updatedFeed = feed ++ [tweet]

    state = {userid, updatedTweets, followers, updatedFeed}

    #IO.inspect(state)
    {:reply, "Added New Tweet", state}
  end

  def handle_call({:updateFeed, tweet}, _from, state) do
    {userid, tweets, followers, feed} = state

    updatedFeed = feed ++ [tweet]
    updatedFeed = Enum.uniq(updatedFeed)

    state = {userid, tweets, followers, updatedFeed}

    #IO.inspect(state)
    {:reply, "Updated Feed", state}
  end

  def handle_call({:updateFollower, follower}, _from, state) do
    {userid, tweets, followers, feed} = state

    updatedFollower = followers ++ [follower]

    state = {userid, tweets, updatedFollower, feed}

    #IO.inspect(state)
    {:reply, "Updated Follower", state}
  end

end
