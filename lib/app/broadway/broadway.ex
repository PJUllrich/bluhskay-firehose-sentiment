defmodule App.Broadway do
  use Broadway

  require Logger

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(App.Broadway,
      name: BroadwayBlueskeyProcessor,
      producer: [
        module: {App.Broadway.Producer, [allowed_messages: 10, interval: :timer.seconds(1)]},
        concurrency: 1
      ],
      processors: [
        decoder: [concurrency: 1]
      ],
      batchers: [
        fetch: [concurrency: 1, batch_size: 25]
      ]
    )
  end

  def handle_message(:decoder, %Message{data: data} = message, _) do
    case process_data(data) do
      {:ok, data} ->
        message
        |> Message.update_data(fn _ -> data end)
        |> Message.put_batcher(:fetch)

      {:skip, reason} ->
        Message.failed(message, reason)
    end
  end

  def handle_batch(:fetch, messages, _batch_info, _context) do
    uris = messages |> Enum.map(& &1.data) |> Enum.uniq()
    IO.inspect(uris)

    case App.Bluesky.get_posts(uris) do
      {:ok, %{body: %{"posts" => posts}}} ->
        Enum.map(messages, fn message ->
          post = Enum.find(posts, fn post -> post["uri"] == message.data end)
          Message.update_data(message, fn _data -> post end)
        end)

      {:error, reason} ->
        Logger.error(inspect(reason))
        Enum.map(messages, fn message -> Message.put_batcher(message, :fetch) end)
    end
  end

  defp process_data({:binary, msg}) do
    with {:ok, _details, post_binary} <- CBOR.decode(msg),
         {:ok, post, _rest} <- CBOR.decode(post_binary) do
      process_data(post)
    else
      error ->
        IO.inspect(error)
    end
  end

  defp process_data(%{
         "ops" => [%{"action" => "create", "path" => "app.bsky.feed.post/" <> id}],
         "repo" => repo
       }) do
    {:ok, "at://#{repo}/app.bsky.feed.post/#{id}"}
  end

  defp process_data(_post), do: {:skip, :not_a_post}
end
