
defmodule Project41.TweetFacility do
  import Ecto.Query

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
#    IO.inspect(hashtag)
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

    # When a tweet is added, one must also add the tweet to respective hashtags

    # When a tweet is added, one must also add the tweet to the feed of the mentioned userids
  end

  def hashtagSearchQuery(hashtag) do

    # @primary_key {:hashid, :binary_id, autogenerate: true}
    # schema "topic_database" do
    #   field :hashtags, :string
    #   field :userids, {:array, :binary_id}
    #   field :tweet, {:array, :binary_id}
    # end
    query = from(user in Project41.Topic, select: user.tweet, where: user.hashtags==^hashtag)
    available_tweets = query |> Project41.Repo.all
#    IO.inspect(available_tweets)
  end

  def sendTweet(userName, tweet) do
    liveUserMap =  Project41.LiveUserServer.get_state()                       #get map of live users from server
    userID = getUserIDFromName(userName)

    if Map.has_key?(liveUserMap, userID) do
      userProcessId = Map.get(liveUserMap, userID)

      [tweet, hashtag, mentions] = Project41.TweetFacility.tweetFormat(tweet)

      Project41.TweetEngine.addTweet(userProcessId, tweet)

      # update the feed of the mentioned users with the current tweet
      updateUserFeed(mentions, liveUserMap, tweet)

      followers = Project41.TweetEngine.getFollowers(userProcessId)

      #update the feed of the followers with the current tweet
      updateUserFeed(followers, liveUserMap, tweet)

    else
        IO.puts "Please log in first"
    end
  end

  def getUserIDFromName(userName) do
    userIDs = from(user in Project41.Userdata, select: user.userid, where: user.username==^userName)
               |> Project41.Repo.all
    if length(userIDs) > 0 do
      [userID|tail] = userIDs
      userID
    else
      nil
    end
  end

  def updateUserFeed(users, liveUserMap, tweet) do
    Enum.each(users, fn userName ->
      userID = getUserIDFromName(userName)
      pid = Map.get(liveUserMap, userID)
      if pid != nil do
        Project41.TweetEngine.updateFeed(pid, tweet)
      end
    end)
  end

end
