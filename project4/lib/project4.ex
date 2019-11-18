defmodule Project4 do
  @moduledoc """
  Documentation for Project4.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Project4.hello()
      :world

  """
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
  def main(tweet) do
    formatted_tweet = tweetFormat(tweet)
    # formatted_tweet holds the tweet in the form of [original_tweet, hashtags, mentions]
    # each of the mentions must be notified about the tweet.
    # the tweet must be added to the list of tweets for a given hashtag
    # each tweet has its own tweet id
    IO.inspect(formatted_tweet)
  end
end
