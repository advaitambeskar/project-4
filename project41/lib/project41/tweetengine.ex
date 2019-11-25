defmodule Project41.TweetEngine do
  use GenServer
  # Each username is associated with its corresponding userID, which becomes the foreign keys for the rest of the
  # stuff
  # When login occurs, a new process is created and the userid is associated with that login. Each process maintains a 'cookie' of sorts
  # that allows the user to log-off
  def init(init_arg) do
    {:ok, init_arg}
  end

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

  # Handle calls and casts for the engine
  def handle_call(:getState, _from, state) do
    {:reply, state, state}
  end

  def subscribe_to_user(userid, username) do

  end
end
