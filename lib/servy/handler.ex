defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts "Warning: 404 encountered for #{path}"
    conv
  end

  def track(conv), do: conv

  def rewrite_path(%{path: "/wildlife"} = conv) do
    %{conv | path: "/wildthings"}
  end

  def rewrite_path(conv), do: conv

  def log(conv), do: IO.inspect(conv)

  def parse(request) do
    [method, path, _] =
      request
      |> String.split("\n")
      |> List.first()
      |> String.split(" ")

    %{method: method, 
      path: path, 
      resp_body: "", 
      status: nil,
    }
  end

  def route(%{ method: "GET", path: "/wildthings"} = conv) do
    %{conv | status: 200, resp_body: "Bears, Lions, Tigers"}
  end

  def route(%{ method: "GET", path: "/bears"} = conv) do
    %{conv | status: 200, resp_body: "Grizzly, Black, Polar"}
  end

  def route(%{ method: "GET", path: "/bears/" <> id} = conv) do
    %{conv | status: 200, resp_body: "Bear id: #{id}"}
  end

  def route(%{ method: "DELETE", path: "/bears/" <> _id} = conv) do
    %{ conv | status: 403, resp_body: "Deleting a bear is forbidden!"}
  end

  def route(%{ path: path} = conv) do
    %{conv | status: 404, resp_body: "#{path} Not Found"}
  end

  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{byte_size(conv.resp_body)}

    #{conv.resp_body}
    """
  end

  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error",
    }[code]
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
