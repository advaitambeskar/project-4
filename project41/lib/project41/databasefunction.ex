defmodule Project41.DatabaseFunction do
  import Ecto.Query

  def addToFeed(userid, tweetid) do
    [user] = from(user in Project41.Feed, select: user, where: user.userid==^userid) |> Project41.Repo.all
      # IO.inspect user

      response = if(user == []) do
        []
      else
        user.tweets
      end
      response = response ++ [tweetid]
      response = Enum.uniq(response)

      [id] = from(user in Project41.Feed, select: user.id, where: user.userid == ^userid)
                          |> Project41.Repo.all
      # IO.inspect "here"
      # IO.inspect id
      struc = Project41.Feed |> Ecto.Query.where(id: ^id) |> Project41.Repo.one
      # IO.inspect struc

      changeset = Project41.Feed.changeset(struc, %{tweets: response})
      Project41.Repo.update(changeset)

      # IO.inspect Project41.Feed |> Ecto.Query.where(id: ^id) |> Project41.Repo.one
      {:ok}
  end

  def addTweetToDB(userid, tweet) do
    [tweet, hashtag, mention] = Project41.TweetFacility.tweetFormat(tweet)
    mentionids = Enum.map(mention, fn x ->
      q = from(user in Project41.Userdata, select: user.userid, where: user.username==^x)
      [answer] = q |> Project41.Repo.all
      answer
    end)

    # IO.inspect hashtag


    hashtagids = Enum.map(hashtag, fn x ->
      # IO.inspect x
      q = from(user in Project41.Topic, select: user.hashid, where: user.hashtags==^x)
      |> Project41.Repo.all
      #IO.inspect "reply"
      #IO.inspect reply
      solution = if(q == []) do
        # IO.inspect x
        newHash = %Project41.Topic{hashid: Ecto.UUID.generate(),
          hashtags: x, userids: [], tweet: []}
        Project41.Repo.insert!(newHash)
        newHash.hashid
        #IO.inspect struc.hashid
      else
        [solution] = q
        # IO.inspect solution
        solution
      end
      # IO.inspect "solution"
      # IO.inspect solution
      solution
    end)


    newTweet = %Project41.Tweetdata{tweetid: Ecto.UUID.generate(),
    tweet: tweet, owner: userid, hashtags: hashtagids, mentions: mentionids}
    #IO.inspect "right before tweet insert"
    Project41.Repo.insert(newTweet)

    # IO.inspect "hashtagids"
    # IO.inspect hashtagids
    # When a tweet is added, one must also add the tweet to respective hashtags
    Project41.DatabaseFunction.addTweetToHashTag(hashtagids, newTweet.tweetid)

    {newTweet.tweetid}
    # When a tweet is added, one must also add the tweet to the feed of the mentioned userids
  end

  def addTweetToHashTag(hashtag, tweetid) do
    Enum.each(hashtag, fn individual_hashid ->
      [entry] = from(user in Project41.Topic, select: user, where: user.hashid==^individual_hashid)
      |> Project41.Repo.all

      response = if(entry == []) do
        []
      else
        entry.tweet
      end

      response = response ++ [tweetid]
      response = Enum.uniq(response)

      struc = Project41.Topic |> Ecto.Query.where(hashid: ^individual_hashid) |> Project41.Repo.one
      changeset = Project41.Topic.changeset(struc, %{tweet: response})
      Project41.Repo.update(changeset)
    end)
  end

  def addFollowerToDatabase(subscriber, username) do
    [userid] = from(user in Project41.Userdata, select: user.userid, where: user.username==^username)
    |> Project41.Repo.all
    IO.inspect userid
    [subscriber_id] = from(user in Project41.Userdata, select: user.userid, where: user.username==^subscriber)
    |> Project41.Repo.all
    IO.inspect subscriber_id

    [entry] = from(user in Project41.Follower, select: user, where: user.userid==^userid)
      |> Project41.Repo.all

      response = if(entry == []) do
        []
      else
        entry.followers
      end
      response = response ++ [subscriber_id]
      response = Enum.uniq(response)
      IO.inspect response
      struc = Project41.Follower |> Ecto.Query.where(userid: ^userid) |> Project41.Repo.one
      changeset = Project41.Follower.changeset(struc, %{followers: response})
      Project41.Repo.update(changeset)
  end

  def subscribeToHashtag(hashtag, username) do
      userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username)
      |> Project41.Repo.all

      hashid = from(user in Project41.Topic, select: user.hashid, where: user.hashtags==^hashtag)
      |> Project41.Repo.all
      [entry] = from(user in Project41.Topic, select: user, where: user.hashid==^hashid)
      |> Project41.Repo.all

      response = if(entry == []) do
        []
      else
        entry.userids
      end

      response = response ++ [userid]
      response = Enum.uniq(response)

      struc = Project41.Topic |> Ecto.Query.where(hashid: ^hashtag) |> Project41.Repo.one
      changeset = Project41.Topic.changeset(struc, %{userids: response})
      Project41.Repo.update(changeset)
  end

  def mentions(username) do
    #return all the tweets which mention the userid
    userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username)
    |> Project41.Repo.all
    if(userid == []) do
      IO.inspect "The username does not exist/ has not been registered."
    else
      [id] = userid
      all_tweet_entries = from(user in Project41.Tweetdata, select: user) |> Project41.Repo.all
      #IO.inspect all_tweet_entries
      possibleTweets = Enum.map(all_tweet_entries, fn each_entry ->
        #IO.inspect each_entry.mentions
        response = if(Enum.member?(each_entry.mentions, id)) do
          each_entry.tweetid
        else
        end
        # IO.inspect "HERE"
        # IO.inspect response
        # answer = Enum.each(each_entry.mentions, fn mentions ->
        #   response = if(Enum.member?(mentions, id)) do
        #     each_entry.tweetid
        #   end
        #   response
        response
        # end)
      end)
      possibleTweets = Enum.filter(possibleTweets, fn x ->
        x != nil
      end)
      response = Enum.map(possibleTweets, fn tweet ->
        m = from(user in Project41.Tweetdata, select: user.tweet, where: user.tweetid==^tweet)
        |> Project41.Repo.all
        m
      end)
      # IO.inspect "response"
      # IO.inspect response
      if(response == []) do
        IO.inspect "No tweets mentioning @#{username} yet"
      else
        res = response
        Enum.map(res, fn x ->
          [tweet] = x
          IO.inspect tweet
        end)
      end
    end
    "All tweets have been printed"
  end
end
