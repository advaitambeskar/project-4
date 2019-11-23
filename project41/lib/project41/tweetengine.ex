defmodule Project41.TweetEngine do
  use GenServer
  # Each username is associated with its corresponding userID, which becomes the foreign keys for the rest of the
  # stuff
  # When login occurs, a new process is created and the userid is associated with that login. Each process maintains a 'cookie' of sorts
  # that allows the user to log-off
  def init(userid, tweets, mentions, followers, feed) do
  {:ok, {userid, tweets, mentions, followers, feed}}
  end


  def start(userid, tweets, mentions, followers, feed) do
    state = {userid, tweets, mentions, followers, feed}
    {:ok, pid} = GenServer.start(__MODULE__, state)
    {pid, state}
  end

  def get_state(pid) do
    GenServer.call(pid, :getState)
  end

  def update_state_add(pid, {atom, values_to_add}) do
    {userids, tweetids, mentionedids} = Project41.TweetEngine.get_state(pid)
    IO.inspect({userids, tweetids, mentionedids})
    cond do
      atom == :updateTweets ->
        tweetids = Tuple.append(tweetids, values_to_add)
        IO.inspect({userids, tweetids, mentionedids})
        GenServer.cast(pid, {:updateState, {userids, tweetids, mentionedids}})
      atom == :updateMentions ->
        mentionedids = Tuple.append(mentionedids, values_to_add)
        IO.inspect({userids, tweetids, mentionedids})
        GenServer.cast(pid, {:updateState, {userids, tweetids, mentionedids}})
    end
  end

  # Handle calls and casts for the engine
  def handle_call(:getState, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:updateState, newstate}, state) do
    state = newstate
    {:noreply, state}
  end
end

defmodule Project41.LoginEngine do
  import Ecto.Query

  @doc """
    Returns: {:atom, {username, password}}
    The function accepts username and password and attempts to register the user, if the user is not
    currently in the list of already logged in users, then it will register a new user and log them in
    If the user is already present, then it will print the message
    The function returns the username and password that will be used to login.

    """
  def registerUser(username, password) do

    newUser = %Project41.Userdata{userid: Ecto.UUID.generate(), username: username, password: password}
    #create the userid that has been generated to
    userid = newUser.userid
    IO.inspect userid
    if(!username_exist(username)) do
      Project41.Repo.insert(newUser)
      #topicEntry
      followerEntry = %Project41.Follower{userid: userid, followers: []}
      Project41.Repo.insert!(followerEntry)
      #feedDatabase

      #create a process here with the created new user.
    else
      IO.inspect "Username already exists, trying to login instead."
    end

    {:login, {username, password}}
  end

  def username_exist(username) do
    reply_from_db = Project41.Userdata |> Project41.Repo.get_by(username: username)
    if(reply_from_db == nil) do
      false
    else
      true
    end
  end


  def login(username, password) do
    query = from(user in Project41.Userdata, select: user.password, where: user.username==^username)
    retrieved_password = query |> Project41.Repo.all
    IO.inspect(retrieved_password)
    if(retrieved_password == [password]) do
      query_userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username)
      retrieved_userid = query_userid |> Project41.Repo.all
      {:loginSuccessful, retrieved_userid}
    else
      {:loginUnsucessful, username}
    end
  end

  def isLogin?(username) do
    # This function needs to be changed when genserver processes are created and such
    # before any function occurs, check if the login is true from the centralized table maintining
    # record of all the logged in users.
    if(true) do
      true
    end
    query = from(user in Project41.Userdata, select: user.userid, where: user.username==^username)
    [retrieved_userid] = query |> Project41.Repo.all

  end

  # Functions to Delete Users - delete occurs only if the user is currently logged in


  # Functions to
end

defmodule Project41.TweetFacility do


  def tweetFormat(tweet) do
    split_tweet = String.split(tweet, " ");
    hashtag = Enum.map(split_tweet, fn x ->
      l = String.length(x);
      if(String.starts_with?(x, "#")) do
        String.slice(x, 1..l)
      end
    end)
    hashtag = Enum.filter(hashtag, fn x ->
      x != nil
    end)

    mention = Enum.map(split_tweet, fn x ->
      l = String.length(x);
      if(String.starts_with?(x, "@")) do
        String.slice(x, 1..l)
      end
    end)
    mention = Enum.filter(mention, fn x->
      x != nil
    end)

    [tweet, hashtag, mention]
  end

  def addTweetToDB(userid, tweet) do
    #
    # schema "tweet_database" do
    #   field :tweet, :string
    #   field :owner, :binary_id
    #   field :hashtags, {:map, :string}
    #   field :mentions, {:map, :binary_id}
    # end
    #
    [tweet, hashtag, mention] = Project41.TweetFacility.tweetFormat(tweet)
    # query = from(user in Project41.Userdata, select: user.password, where: user.username==^username)
    # newTweet = %Project41.Tweetdata.
  end
end
