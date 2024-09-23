defmodule App.Simplified.Broadway do
  use Broadway

  require Logger

  alias Broadway.Message

  def start_link(_opts) do
    Broadway.start_link(App.Simplified.Broadway,
      name: BroadwayBlueskeySimplified,
      producer: [
        module: {App.Simplified.Producer, []},
        concurrency: 1
      ],
      processors: [
        default: [concurrency: 1]
      ],
      batchers: [
        default: [concurrency: 1, batch_size: 10]
      ]
    )
  end

  @impl true
  def handle_message(:default, %Message{data: {:text, event}} = message, _context) do
    case Jason.decode(event) do
      {:ok, %{"commit" => %{"record" => %{"langs" => ["en"], "text" => text}}}} ->
        Message.put_data(message, text)

      {:ok, _message} ->
        Message.failed(message, "Non-english post")

      {:error, reason} ->
        Logger.error(inspect(reason))
        Message.failed(message, "Decoding error")
    end
  end

  @impl true
  def handle_batch(:default, messages, _batch_info, _context) do
    Logger.info(Enum.map(messages, & &1.data))
    messages
  end
end
