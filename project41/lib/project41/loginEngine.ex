#  Contains username_exist(username) which returns {boolean, userid} where userid = [] if boolean is false
#  userid = [userid] if boolean is true
#  Contains isLogin?(username) which returns true or false depending on whether the username is currently
#  logged in

defmodule Project41.LoginEngine do
  import Ecto.Query

  def registerUser(username, password) do

    newUser = %Project41.Userdata{userid: Ecto.UUID.generate(), username: username, password: password}
    #create the userid that has been generated to
    userid = newUser.userid
    #IO.inspect userid
    {reply, answer} = Project41.LoginEngine.username_exist(username)
    if(!reply) do
      Project41.Repo.insert(newUser)
      #topicEntry
      followerEntry = %Project41.Follower{userid: userid, followers: []}
      Project41.Repo.insert!(followerEntry)
      #feedDatabase
      feedEntry = %Project41.Feed{userid: userid, tweets: []}
      Project41.Repo.insert!(feedEntry)
      #create a process here with the created new user.
      {:newUser}
    else
      {:oldUser}
    end
  end

  def deleteUser(username, password) do
    #IO.inspect "WEA"
    {reply, userid} = username_exist(username)
    if(reply) do
      #IO.inspect "WER"
      retrieved_password = from(user in Project41.Userdata, select: user.password, where: user.username==^username) |> Project41.Repo.all
      retrieved_userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
      [uid] = userid
      if(Project41.LoginEngine.isLogin?(username)) do
        #IO.inspect "here and there"
        if(retrieved_password = [password]) do
          #IO.inspect "here"
          Project41.LoginEngine.logout(username)
          user = Project41.Repo.get(Project41.Userdata, uid)
          # IO.inspect user
          Project41.Repo.delete(user)
          "User #{username} has been successfully deleted."
        else
          "Incorrect password, cannot delete user."
        end
      else
        "You need to login before you delete the user."
      end
    else
      "Sorry, the user you are trying to delete does not exist."
    end
  end

  def username_exist(username) do
    userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
    #IO.inspect userid
    if(userid == []) do
      {false, []}
    else
      {true, userid}
    end
  end

  def isUserNameValid(username) do
    userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
    #IO.inspect userid
    if(userid == []) do
      false
    else
      true
    end
  end


  def login(username, password) do
    retrieved_password = from(user in Project41.Userdata, select: user.password, where: user.username==^username) |> Project41.Repo.all
    #IO.inspect(retrieved_password)

    if(retrieved_password == [password]) do
      retrieved_userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
      logged_in_Users = Project41.LiveUserServer.get_state()
      [uid] = retrieved_userid
      if(Map.has_key?(logged_in_Users, uid)) do
        {:duplicateLogin, username}
      else
        {:loginSuccessful, retrieved_userid}
      end
    else
      {:loginUnsucessful, username}
    end

  end

  def logout(username) do
    userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
    logged_in_Users = Project41.LiveUserServer.get_state()

    if userid != [] do
      [uid] = userid

      if(isLogin?(username)) do
        {reply, processid} = Map.fetch(logged_in_Users, uid)

        Process.exit(processid, :kill)
        Project41.LiveUserServer.userLogOut(uid)
        "Successfully signed out #{username} of the app."
      else
        "You are trying to log out a user that is not currently logged in."
      end
    else
      "You are attempting to log out a user that does not exist. Please check again"
    end
  end

  def isLogin?(username) do
    retrieved_userid = from(user in Project41.Userdata, select: user.userid, where: user.username==^username) |> Project41.Repo.all
    [user_id] = retrieved_userid

    logged_in_Users = Project41.LiveUserServer.get_state()
    if(Map.has_key?(logged_in_Users, user_id)) do
      true
    else
      false
    end
  end
end
