defmodule Project41.LiveUserServer do
  use GenServer

  @server Project41.LiveUserServer
  @processName :"LiveUserServer"

  def start_link() do
    # name of the server
    GenServer.start_link(@server, %{}, name: @processName)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  def userLogedIn(pid, userid) do
    processID = Process.whereis(@processName)
    GenServer.call(processID, {:userLoggedIn, pid, userid})

  end

  def handle_call({:userLoggedIn, pid, userid}, _from, state) do
    map = state
    map = Map.put(map, userid, pid)
    IO.inspect(map)
    {:reply, "Updated live users", map}
  end

  def userLogedOut(userid) do
    processID = Process.whereis(@processName)
    GenServer.call(processID, {:userLoggedOut, userid})
  end

  def handle_call({:userLoggedOut, userid}, _from, state) do
    map = state
    Map.delete(map, userid)
    {:reply, "Updating State", map}
  end
end

