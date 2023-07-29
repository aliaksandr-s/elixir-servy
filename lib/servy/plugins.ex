defmodule Servy.Plugins do
  require Logger
  alias Servy.Conv
  alias Servy.FourOhFourCounter, as: Counter

  def track(%Conv{status: 404, path: path} = conv) do
    Counter.bump_count(path)
    Logger.warning "404 encountered for #{path}"
    conv
  end

  def track(%Conv{} = conv) do
    if Mix.env != :test do
      IO.puts "Warning: #{conv.path} is on the loose!"
    end
    conv
  end

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect conv
    end
    conv
  end
end

