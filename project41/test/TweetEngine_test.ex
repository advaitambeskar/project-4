defmodule TweetEngineTest do
  use ExUnit.Case, async: true

  test "test_register_to_user" do
    Project41.ClientFunctions.login("hello", "pwd")
    Project41.ClientFunctions.login("hi", "pwd")
    reply = Project41.TweetEngine.subscribe_to_user("hello", "hi")
    expected_reply = "@hello has successfully begun following @hi"
    assert reply = expected_reply
  end

end