defmodule Server do
  @moduledoc """
  Module to handle all the calls to the Server
  """
  use GenServer

  def start_link(opts \\ []) do
    {:ok, _pid} = GenServer.start_link(Server, [], opts)
  end

  def init(args) do
    indicator_r = 0 # For the ReadActor
    indicator_w = 0 # For the WriteActor
    indicator_s = 0 # This is for the TweetActors
    sequenceNum = 0
    request_hitcount = 0
    state = {:running, indicator_r, indicator_w, indicator_s, sequenceNum, request_hitcount}

   Enum.each(0..1000, fn(index)->
     actorName = "readActor"<>Integer.to_string(index) |> String.to_atom()
     GenServer.start(ReadTweets, :running, name: actorName)
   end)
   Enum.each(0..1000, fn(index)->
     actorName = "tweetActor"<>Integer.to_string(index) |> String.to_atom()
     GenServer.start(TweetActors, :running, name: actorName)
   end)
   # GenServer.start(ReadTweets, :running, name: :readActor1)
   # GenServer.start(ReadTweets, :running, name: :readActor2)
   GenServer.start(WriteTweet, :running, name: :writeActor1)
   GenServer.start(WriteTweet, :running, name: :writeActor2)
   {:ok, state}
 end
  # Below Won't be used in the current implementation
  def handle_call(:start, from, state) do
    # ServerApi.startNode()
    # Engine.initTables()
    {:reply, :started, state}
  end
  # handle call for registering a new process,
  # needs to be handle call only since can't tweet until registered

  # handle_cast to subscribe user/client to another user/client
  # LOGOUT and LOGIN

  #-----------------------------------------------------------------------------
  # Write and send tweets to subscribers
   #-----------------------------------------------------------------------------
   # Handle search requests by clients
end
