alias Project41.ClientFunctions, as: Client
alias Project41.TweetFacility, as: Tweet

defmodule Project41.Demo do

  def initiate(users, tweets) do
    register_users(users)

    subscribe_users(users)

    send_tweets(users, tweets)
  end

  def register_users(users) do
    Enum.each(1..users,
      fn index ->
        user_name = "User_#{index}"
        password = "Pwd_#{index}"

        Client.register(user_name, password)
      end)
  end

  def subscribe_users(users) do
    subscribe_count = 5

    Enum.each(1..users,
      fn index ->
        current_user = "User_#{index}"
        subscribe_limit = :rand.uniform(subscribe_count)

        Enum.each(1..subscribe_limit,
             fn counter ->
               random_user_index = :rand.uniform(users)

               random_user = "User_#{random_user_index}"

               Client.subscribeToUser(current_user, random_user)
             end)
      end)
  end

  def send_tweets(users, tweets) do
    Enum.each(1..users, fn user_index ->
      user_name = "User_#{user_index}"
      should_mention = Enum.random([0, 1])

      Enum.each(1..tweets, fn tweet_id ->
        tweet_message = if should_mention == 1 do
            random_user_index = :rand.uniform(users)
            random_user = "User_#{random_user_index}"

            "This is Tweet #{tweet_id} for @#{random_user}"
          else
            "This is Tweet #{tweet_id}"
          end
        Tweet.sendTweet(user_name, tweet_message)
      end)
    end)
  end

end