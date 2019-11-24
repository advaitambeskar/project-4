defmodule Project41.Client do
  def main() do
    {reply, {username, password}} = Project41.LoginEngine.registerUser("adambeskar", "advait")
    if reply == :login do
      {login_reply, [userid]} = Project41.LoginEngine.login(username, password)
      if login_reply == :loginSuccessful do
        tweets = [] # extract tweets
        # Project41.Tweetdata
        mentions = [] # extract mentions
        followers = [] # extract followers
        # Project41.Follower
        feed = [] # extract feed
        # Project41.Feed
        {pid, client_state} = Project41.TweetEngine.start(userid, tweets, mentions, followers, feed)
        Project41.LiveUserServer.userLogedIn(pid, userid)
        client_state
      end
    end
  end
end