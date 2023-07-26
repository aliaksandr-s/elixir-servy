defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [4000])

    {:ok, response} = :httpc.request(:get, {'http://localhost:4000/wildthings', ''}, [], [])
    {_http_version, status_code, _status_message} = response |> elem(0)
    body = response |> elem(2) |> to_string

    assert status_code == 200
    assert body == "Bears, Lions, Tigers"
  end
end
