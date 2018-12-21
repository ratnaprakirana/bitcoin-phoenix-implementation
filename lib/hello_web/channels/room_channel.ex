defmodule HelloWeb.RoomChannel do
    use Phoenix.Channel

    def join("room:lobby", _message, socket) do
        {:ok, socket}
    end
    def join("room:"<> _private_room_id, _params, _socket) do
        {:error, %{reason: "unauthorized"}}
    end

    def handle_in("start_mining", params, socket) do
    #  GenServer.cast(:server, {:start_mining, userName})
        Bitcoin.Project4.process(socket)
      {:noreply, socket}
    end




end
