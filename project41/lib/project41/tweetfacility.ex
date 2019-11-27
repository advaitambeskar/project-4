
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



  def hashtagSearchQuery(hashtag) do

    # @primary_key {:hashid, :binary_id, autogenerate: true}
    # schema "topic_database" do
    #   field :hashtags, :string
    #   field :userids, {:array, :binary_id}
    #   field :tweet, {:array, :binary_id}
    # end
    query = from(user in Project41.Topic, select: user.tweet, where: user.hashtags==^hashtag)
    available_tweets = query |> Project41.Repo.all
    count = 0;
    response = if(available_tweets == []) do
      []
    else
      # IO.inspect "what"
      # IO.inspect(available_tweets)
      [tweet_list] = available_tweets
      tweet_list
    end
    IO.inspect "The following tweets have been published for ##{hashtag} in the lifetime"
    Enum.each(response, fn tweet_id ->
      [tweet_string] = from(user in Project41.Tweetdata, select: user.tweet, where: user.tweetid==^tweet_id)
      |> Project41.Repo.all
      [tweet_owner] = from(user in Project41.Tweetdata, select: user.owner, where: user.tweetid==^tweet_id)
      |> Project41.Repo.all
      tweet_owner_name = from(user in Project41.Userdata, select: user.username, where: user.userid==^tweet_owner)
      |> Project41.Repo.all

      newTweetFormat = "@#{tweet_owner_name} tweeted '#{tweet_string}'"
      IO.puts newTweetFormat
    end)
    if(Enum.count(response) != 0) do
      "These are all the tweets published on ##{hashtag}"
    else
      "There are no tweets published on ##{hashtag} yet"
    end
  end

  def userSearchQuery(user) do

    # @primary_key {:hashid, :binary_id, autogenerate: true}
    # schema "topic_database" do
    #   field :hashtags, :string
    #   field :userids, {:array, :binary_id}
    #   field :tweet, {:array, :binary_id}
    # end
    userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^user)
    |> Project41.Repo.all

    response = if(userid == []) do
      []
    else
      # IO.inspect "what"
      # IO.inspect(available_tweets)
      [user_id] = userid
      tweet_list = from(user in Project41.Tweetdata, select: user.tweetid, where: user.owner==^user_id)
      |> Project41.Repo.all
      tweet_list
    end
    #IO.inspect response
    if(response != []) do
      IO.inspect "The following tweets have been published for @#{user} in the lifetime"
      Enum.each(response, fn tweet_id ->
        [tweet_string] = from(user in Project41.Tweetdata, select: user.tweet, where: user.tweetid==^tweet_id)
        |> Project41.Repo.all
        [tweet_owner] = from(user in Project41.Tweetdata, select: user.owner, where: user.tweetid==^tweet_id)
        |> Project41.Repo.all
        tweet_owner_name = from(user in Project41.Userdata, select: user.username, where: user.userid==^tweet_owner)
        |> Project41.Repo.all

        newTweetFormat = "@#{tweet_owner_name} tweeted '#{tweet_string}'"
        IO.puts newTweetFormat
      end)
      if(Enum.count(response) == 0) do
        IO.puts "\n"
        "There are no associated tweets by @#{user}"
      else
        IO.puts "\n"
        "These are all the tweets published on @#{user}"
      end
    else
      "No user associated with #{user}"
    end
  end

  def sendTweet(userName, tweet) do
    liveUserMap =  Project41.LiveUserServer.get_state() #get map of live users from server
    [userID] = from(user in Project41.Userdata, select: user.userid, where: user.username==^userName)
      |> Project41.Repo.all
    # IO.inspect userID
    if Map.has_key?(liveUserMap, userID) do
      userProcessId = Map.get(liveUserMap, userID)

      [tweet, hashtag, mentions] = Project41.TweetFacility.tweetFormat(tweet)
      {tweetid} = Project41.DatabaseFunction.addTweetToDB(userID, tweet)

      # Enum.each(hashtag, fn x ->
      #   Project41.DatabaseFunction.addTweetToHashTag(x, tweetid)
      # end)
      # IO.puts "tweetid"
      # IO.inspect(tweetid)
      Project41.TweetEngine.addTweet(userProcessId, tweetid)

      # update the feed of the mentioned users with the current tweet
      Project41.TweetFacility.updateUserFeed(mentions, liveUserMap, tweetid)

      followers = Project41.TweetEngine.getFollowers(userProcessId)
      follower_name = Enum.map(followers, fn x ->
        q = from( user in Project41.Userdata, select: user.username, where: user.userid== ^x)
        [answer] = q |> Project41.Repo.all
        answer
      end)
      #update the feed of the followers with the current tweet
      updateUserFeed(follower_name, liveUserMap, tweetid)

      # Updating the Feed Database
      Project41.DatabaseFunction.addToFeed(userID, tweetid)
      # Project41.Repo.update!(changeset)
      IO.inspect "Tweet added to feed"
    else
        IO.puts "Please log in first"
    end
  end



  def reTweet(userName, tweetid) do
    [tweet] = from(user in Project41.Tweetdata, select: user.tweet, where: user.tweetid==^tweetid)
                      |> Project41.Repo.all
    [tweetOwner] = from(user in Project41.Tweetdata, select: user.owner, where: user.tweetid==^tweetid)
                 |> Project41.Repo.all
    [ownerName] = from(user in Project41.Userdata, select: user.username, where: user.userid==^tweetOwner)
                  |> Project41.Repo.all
    prefix = "re-tweet by #{ownerName} -> "
    retweet = prefix <> tweet

    sendTweet(userName, retweet)

  end

  def getUserIDFromName(userName) do
    userIDs = from(user in Project41.Userdata, select: user.userid, where: user.username==^userName)
               |> Project41.Repo.all
    if length(userIDs) > 0 do
      [userID|_tail] = userIDs
      userID
    else
      nil
    end
  end

  def updateUserFeed(users, liveUserMap, tweet) do
    Enum.each(users, fn userName ->
      userID = getUserIDFromName(userName)
      pid = Map.get(liveUserMap, userID)
      IO.inspect "in update user feed"
      IO.inspect tweet
      IO.inspect userID
      if pid != nil do
        Project41.TweetEngine.updateFeed(pid, tweet)
        Project41.DatabaseFunction.addToFeed(userID, tweet)

      end
      {:ok}
    end)
  end

end
