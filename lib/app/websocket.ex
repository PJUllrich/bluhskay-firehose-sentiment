defmodule App.WebSocket do
  use WebSockex

  require Logger

  @buffer_size 1000
  @url "wss://bsky.network/xrpc/com.atproto.sync.subscribeRepos"

  def start_link(_args) do
    buffer = CircularBuffer.new(@buffer_size)
    WebSockex.start_link(@url, __MODULE__, buffer)
  end

  def handle_frame(event, buffer) do
    buffer = CircularBuffer.insert(buffer, event)
    {:ok, buffer}
  end
end
