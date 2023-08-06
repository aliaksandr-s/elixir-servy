defmodule Servy.SensorServer do

  use GenServer

  @name :sensor_server

  defmodule State do
    defstruct [
      sensor_data: %{},
      refresh_interval: :timer.minutes(60) #:timer.seconds(5)
    ]
  end

  # Client Interface
  def start_link(interval) do
    IO.puts "Starting the SensorServer with interval #{interval}..."
    initial_state = %State{refresh_interval: interval}
    GenServer.start_link(__MODULE__, initial_state, name: @name)
  end

  def get_sensor_data do
    GenServer.call @name, :get_sensor_data
  end

  def set_refresh_interval(interval) do
    GenServer.call @name, {:set_refresh_interval, interval}
  end

  # Server Callbacks
  def init(state) do
    sensor_data = run_tasks_to_get_sensor_data()
    initial_state = %{state | sensor_data: sensor_data}
    schedule_refresh(state.refresh_interval)
    {:ok, initial_state}
  end

  def handle_info(:refresh, state) do
    IO.puts "Refreshing the cache..."
    sensor_data = run_tasks_to_get_sensor_data()
    new_state = %{state | sensor_data: sensor_data}
    schedule_refresh(state.refresh_interval)
    {:noreply, new_state}
  end

  def handle_info(unexpected, state) do
    IO.puts "Can't touch this! #{inspect unexpected}"
    {:noreply, state}
  end

  defp schedule_refresh(interval) do
    Process.send_after(self(), :refresh, interval)
  end

  def handle_call(:get_sensor_data, _from, state) do
    {:reply, state.sensor_data, state}
  end

  def handle_call({:set_refresh_interval, interval}, _from, state) do
    new_state = %{state | refresh_interval: interval}
    {:reply, :ok, new_state}
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts "Running tasks to get sensor data..."

    task = Task.async(fn -> Servy.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servy.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end
