defmodule App.Broadway.Producer do
  @behaviour Broadway.Producer

  alias Broadway.Message

  def start_link(_argse) do
    GenStage.start_link(__MODULE__, [])
  end

  def init(_opts) do
    {:producer, 0}
  end

  def handle_demand(demand, counter) when demand > 0 do
    events = App.Buffer.get_events(demand)

    messages =
      Enum.map(events, fn event ->
        %Message{data: event, acknowledger: Broadway.NoopAcknowledger.init()}
      end)

    {:noreply, messages, counter + demand}
  end

  def handle_demand(_demand, counter), do: {:noreply, [], counter}
end
