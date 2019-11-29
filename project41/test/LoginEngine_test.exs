defmodule LoginEngineTest do
  use ExUnit.Case, async: true

  test "test_register_user" do
    {reply} = Project41.LoginEngine.registerUser("meenu", "pwd")
    assert reply != nil
    assert reply == :newUser || :oldUser
  end

  test "test_username-exists" do
    Project41.LoginEngine.registerUser("hello", "pwd")
    {reply,_} = Project41.LoginEngine.username_exist("hello")
    assert reply == true
  end

  test "test_is_username_valid" do
    Project41.ClientFunctions.register("goodbye", "pwd")
    Project41.ClientFunctions.login("goodbye", "pwd")
    reply = Project41.LoginEngine.isUserNameValid("goodbye")
    assert reply == true
  end

  test "login" do
    Project41.LoginEngine.login("hi", "pwd")
    {reply, _} = Project41.LoginEngine.login("hi", "pwd")
    expected_output = :loginUnsucessful
    assert reply == expected_output
  end

  test "is_logged_in" do
     Project41.ClientFunctions.register("hello", "pwd")
     Project41.ClientFunctions.login("hello", "pwd")
     reply = Project41.LoginEngine.isLogin?("hello")
     assert reply == true
  end

  test "log_out" do
    Project41.ClientFunctions.register("hello", "pwd")
    reply = Project41.LoginEngine.deleteUser("hello", "pwd")
    expected_reply = "User hello has been successfully deleted."
    assert reply == expected_reply

  end
end
