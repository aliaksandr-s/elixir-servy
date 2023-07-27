defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts a request on a socket and sends back a response (using httpc)" do
    spawn(HttpServer, :start, [4000])

    {:ok, response} = :httpc.request(:get, {'http://localhost:4000/wildthings', ''}, [], [])
    {_http_version, status_code, _status_message} = response |> elem(0)
    body = response |> elem(2) |> to_string

    assert status_code == 200
    assert body == "Bears, Lions, Tigers"
  end

  test "accepts a request on a socket and sends back a response (using httpoison)" do
    spawn(HttpServer, :start, [4000])

    parent = self()

    max_concurrent_requests = 5

    # Spawn the client processes
    for _ <- 1..max_concurrent_requests do
      spawn(fn ->
        # Send the request
        {:ok, response} = HTTPoison.get "http://localhost:4000/wildthings"

        # Send the response back to the parent
        send(parent, {:ok, response})
      end)
    end

    # Await all {:handled, response} messages from spawned processes.
    for _ <- 1..max_concurrent_requests do
      receive do
        {:ok, response} ->
          assert response.status_code == 200
          assert response.body == "Bears, Lions, Tigers"
      end
    end
  end
end
