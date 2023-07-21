defmodule Servy.Handler do
  @moduledoc "Handles HTTP requests"

  @pages_path Path.expand("pages", File.cwd!)

  import Servy.Plugins, only: [track: 1, rewrite_path: 1, log: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2]

  alias Servy.Conv
  alias Servy.BearController

  @doc "Transforms an HTTP request into an HTTP response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> emojify
    |> format_response
  end

  def route(%Conv{method: "GET", path: "/about"} = conv) do
      @pages_path
      |> Path.join("about.html")
      |> File.read
      |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%Conv{ method: "GET", path: "/bears/new"} = conv) do
    Path.expand("../../pages", __DIR__)
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears"} = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> _id} = conv) do
    BearController.delete(conv)
  end

  def route(%Conv{ path: path} = conv) do
    %{conv | status: 404, resp_body: "#{path} Not Found"}
  end

  def emojify(%Conv{status: 200, resp_body: body} = conv) do
    %{conv | resp_body: "😀 " <> body <> " 😆"}
  end

  def emojify(%Conv{} = conv), do: conv

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 "#{Conv.full_status(conv)}"
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response = Servy.Handler.handle(request)
IO.puts(response)

request_2 = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_2 = Servy.Handler.handle(request_2)
IO.puts(response_2)

request_3 = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_3 = Servy.Handler.handle(request_3)
IO.puts(response_3)

request_4 = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_4 = Servy.Handler.handle(request_4)
IO.puts(response_4)

request_5 = """
DELETE /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_5 = Servy.Handler.handle(request_5)
IO.puts(response_5)

request_6 = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_6 = Servy.Handler.handle(request_6)
IO.puts(response_6)

request_7 = """
GET /bears?id=1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_7 = Servy.Handler.handle(request_7)
IO.puts(response_7)

request_8 = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_8 = Servy.Handler.handle(request_8)
IO.puts(response_8)

request_9 = """
GET /bears/new HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

response_9 = Servy.Handler.handle(request_9)
IO.puts(response_9)

request_10 = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

response_10 = Servy.Handler.handle(request_10)

IO.puts response_10
