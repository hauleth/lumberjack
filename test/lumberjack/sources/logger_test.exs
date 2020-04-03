defmodule Lumberjack.Sources.LoggerTest do
  use ExUnit.Case

  require Logger

  @subject Lumberjack.Sources.Logger

  doctest @subject

  @tag capture_log: true
  test "messages sent to Erlang logger pop out in stream" do
    stream = Lumberjack.stream()

    :logger.debug("Hello")

    assert [%Lumberjack.Event{data: %{msg: "Hello", level: :debug}}] = Enum.to_list(Stream.take(stream, 1))
  end

  @tag capture_log: true
  test "messages sent to Elixir logger pop out in stream" do
    stream = Lumberjack.stream()

    Logger.info("Hello")

    assert [%Lumberjack.Event{data: %{msg: "Hello", level: :info}}] = Enum.to_list(Stream.take(stream, 1))
  end
end
