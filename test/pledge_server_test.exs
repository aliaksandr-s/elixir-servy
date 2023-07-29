defmodule PledgeServerTest do
  use ExUnit.Case

  alias Servy.PledgeServer
  PledgeServer.start()

  test "caches only the 3 most recent pledges" do
    PledgeServer.create_pledge("Alice", 100)
    PledgeServer.create_pledge("Bob", 200)
    PledgeServer.create_pledge("Charlie", 300)
    PledgeServer.create_pledge("Diane", 400)

    recent_pledges = PledgeServer.recent_pledges()

    assert recent_pledges == [
      {"Diane", 400},
      {"Charlie", 300},
      {"Bob", 200}
    ]
  end

  test "returns the total pledged amount" do
    PledgeServer.create_pledge("Alice", 100)
    PledgeServer.create_pledge("Bob", 200)
    PledgeServer.create_pledge("Charlie", 300)
    PledgeServer.create_pledge("Diane", 400)

    total_pledged = PledgeServer.total_pledged()

    assert total_pledged == 900
  end
end
