defmodule TweetFacilityTest do
  import ExUnit.CaptureIO
  use ExUnit.Case, async: true

  test "test_tweet_format" do
   currentTweet = "hi all @tweety"
   [tweet, hashtag, mention] = Project41.TweetFacility.tweetFormat(currentTweet)
   assert tweet == currentTweet
   assert hashtag == []
   assert mention == ["tweety"]
  end
end
