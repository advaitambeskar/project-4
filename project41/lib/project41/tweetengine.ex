defmodule Project41.TweetEngine do
  use GenServer
  # Each username is associated with its corresponding userID, which becomes the foreign keys for the rest of the
  # stuff
  # When login occurs, a new process is created and the userid is associated with that login. Each process maintains a 'cookie' of sorts
  # that allows the user to log-off
  def init(userid, tweetids, mentionedids) do
  {:ok, {userid, tweetids, mentionedids}}
  end


  def start(userid, tweetids, mentionedids) do
    state = {userid, tweetids, mentionedids}
    {:ok, pid} = GenServer.start(__MODULE__, state)
    {pid, state}
  end

  def get_state(pid) do
    GenServer.call(pid, :getState)
  end

  def update_state_add(pid, {atom, values_to_add}) do
    {userids, tweetids, mentionedids} = Project41.TweetEngine.get_state(pid)
    IO.inspect({userids, tweetids, mentionedids})
    cond do
      atom == :updateTweets ->
        tweetids = Tuple.append(tweetids, values_to_add)
        IO.inspect({userids, tweetids, mentionedids})
        GenServer.cast(pid, {:updateState, {userids, tweetids, mentionedids}})
      atom == :updateMentions ->
        mentionedids = Tuple.append(mentionedids, values_to_add)
        IO.inspect({userids, tweetids, mentionedids})
        GenServer.cast(pid, {:updateState, {userids, tweetids, mentionedids}})
    end
  end

  # Handle calls and casts for the engine
  def handle_call(:getState, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:updateState, newstate}, state) do
    state = newstate
    {:noreply, state}
  end
end

defmodule Project41.LoginEngine do
  import Ecto.Query

  # Functions to Register Users
  def registerUser(username, name, password) do
    userID = Ecto.UUID.generate()
    newUser = %Project41.Userdata{userid: userID, username: username, name: name, password: password}
    if(!username_exist(username)) do
      Project41.Repo.insert(newUser)
    else
      login(username, password)
    end
  end

  def username_exist(username) do
    reply_from_db = Project41.Userdata |> Project41.Repo.get_by(username: username)
    if(reply_from_db == nil) do
      false
    else
      true
    end
  end


  def login(username, password) do
    query = from(user in Project41.Userdata, select: user.password, where: user.username==^username)
    [retrieved_password] = query |> Project41.Repo.all
    IO.inspect(retrieved_password)
    if(retrieved_password == password) do
      query_userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username)
      retrieved_userid = query_userid |> Project41.Repo.all
      {retrieved_userid, :loginSuccessful}
    else
      {username, :loginUnsucessful}
    end
  end

  # Functions to Delete Users - delete occurs only if the user is currently logged in


  # Functions to
end
