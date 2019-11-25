defmodule Project41.TweetEngine do
  use GenServer
  # Each username is associated with its corresponding userID, which becomes the foreign keys for the rest of the
  # stuff
  # When login occurs, a new process is created and the userid is associated with that login. Each process maintains a 'cookie' of sorts
  # that allows the user to log-off
  def init(userid, tweets, mentions, followers, feed) do
  {:ok, {userid, tweets, mentions, followers, feed}}
  end

  def start(userid, tweets, followers, feed) do
    state = {userid, tweets, followers, feed}
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
    #IO.inspect userid
    {reply, answer} = username_exist(username)
    if(!reply) do
      Project41.Repo.insert(newUser)
      #topicEntry
      followerEntry = %Project41.Follower{userid: userid, followers: [userid]}
      Project41.Repo.insert!(followerEntry)
      #feedDatabase
      feedEntry = %Project41.Feed{userid: userid, tweets: []}
      Project41.Repo.insert!(feedEntry)
      #create a process here with the created new user.
      {:newUser}
    else
      {:oldUser}
    end
  end
  def deleteUser(username, password) do
    #IO.inspect "WEA"
    {reply, userid} = username_exist(username)
    if(reply) do
      #IO.inspect "WER"
      retrieved_password = from(user in Project41.Userdata, select: user.password, where: user.username==^username) |> Project41.Repo.all
      retrieved_userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
      [uid] = userid
      if(Project41.LoginEngine.isLogin?(username)) do
        #IO.inspect "here and there"
        if(retrieved_password = [password]) do
          #IO.inspect "here"
          Project41.LoginEngine.logout(username)
          user = Project41.Repo.get(Project41.Userdata, uid)
          # IO.inspect user
          Project41.Repo.delete(user)
          "User #{username} has been successfully deleted."
        else
          "Incorrect password, cannot delete user."
        end
      else
        "You need to login before you delete the user."
      end
    else
      "Sorry, the user you are trying to delete does not exist."
    end
  end

  def username_exist(username) do
    userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
    #IO.inspect userid
    if(userid == []) do
      {false, []}
    else
      {true, userid}
    end
  end


  def login(username, password) do
    retrieved_password = from(user in Project41.Userdata, select: user.password, where: user.username==^username) |> Project41.Repo.all
    #IO.inspect(retrieved_password)

    if(retrieved_password == [password]) do
      retrieved_userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
      logged_in_Users = Project41.LiveUserServer.get_state()
      [uid] = retrieved_userid
      if(Map.has_key?(logged_in_Users, uid)) do
        {:duplicateLogin, username}
      else
        {:loginSuccessful, retrieved_userid}
      end
    else
      {:loginUnsucessful, username}
    end

  end

  def logout(username) do
    userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
    logged_in_Users = Project41.LiveUserServer.get_state()

    if userid != [] do
      [uid] = userid

      if(isLogin?(username)) do
        {reply, processid} = Map.fetch(logged_in_Users, uid)

        Process.exit(processid, :kill)
        Project41.LiveUserServer.userLogOut(uid)
        "Successfully signed out #{username} of the app."
      else
        "You are trying to log out a user that is not currently logged in."
      end
    else
      "You are attempting to log out a user that does not exist. Please check again"
    end
  end

  def isLogin?(username) do
    retrieved_userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
    [user_id] = retrieved_userid

    logged_in_Users = Project41.LiveUserServer.get_state()

    if(Map.has_key?(logged_in_Users, user_id)) do
      true
    else
      false
    end
  end
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
    # @primary_key {:tweetid, :binary_id, autogenerate: true}
    # schema "tweet_database" do
    #   field :tweet, :string
    #   field :owner, :binary_id
    #   field :hashtags, {:map, :string}
    #   field :mentions, {:map, :binary_id}
    # end
    #
    [tweet, hashtag, mention] = Project41.TweetFacility.tweetFormat(tweet)
    # query = from(user in Project41.Tweetdata, select: user.password, where: user.username==^username)
    newTweet = %Project41.Tweetdata{tweetid: Ecto.UUID.generate(),
    tweet: tweet, owner: userid, hashtags: hashtag, mentions: mention}
    Project41.Repo.insert(newTweet)
  end

  def hashtagSearchQuery(hashtag) do
    # returns the tweets that are associated with the hashtag
    # returned the tweetids
  end
end
