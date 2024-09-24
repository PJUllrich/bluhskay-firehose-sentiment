defmodule App.Dumper do
  use GenServer

  require Logger

  @interval :timer.minutes(1)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def add(sum, count) do
    GenServer.cast(__MODULE__, {:add, sum, count})
  end

  def init(_args) do
    schedule_dump()
    {:ok, {0.0, 0}}
  end

  def handle_cast({:add, new_sum, new_count}, {sum, count}) do
    {:noreply, {new_sum + sum, new_count + count}}
  end

  def handle_info(:dump, {sum, count}) do
    schedule_dump()
    Logger.info("Dump: #{sum} #{count} - #{sum / count}")
    {:noreply, {0.0, 0}}
  end

  defp schedule_dump() do
    Process.send_after(self(), :dump, @interval)
  end
end