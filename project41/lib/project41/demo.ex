alias Project41.ClientFunctions, as: Client
alias Project41.TweetFacility, as: Tweet

defmodule Project41.Demo do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    {:ok, args}
  end

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

  def handle_call(:start, _from, args) do

    IO.puts("starting demo...")

    cond do
      length(args) == 2->
        [numberOfUsers, numberOfTweets] = args
        users = String.to_integer(numberOfUsers)
        tweets = String.to_integer(numberOfTweets)

        register_users(users)

        subscribe_users(users)

        send_tweets(users, tweets)

      true ->
        IO.puts("The number of arguments is invalid")
        System.halt(0)
    end

    {:reply, "Demo finished", args}
  end

end