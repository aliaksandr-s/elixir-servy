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

    urls = [
      "http://localhost:4000/wildthings",
      "http://localhost:4000/about",
      "http://localhost:4000/bears/new",
      "http://localhost:4000/bears",
      "http://localhost:4000/api/bears",
    ]

    urls
    |> Enum.map(&Task.async(fn -> HTTPoison.get(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
  end
end
