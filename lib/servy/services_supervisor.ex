defmodule Servy.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts "Starting the ServicesSupervisor..."
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      Servy.PledgeServer,
      {Servy.SensorServer, :timer.seconds(10)},
      Servy.FourOhFourCounter,
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
