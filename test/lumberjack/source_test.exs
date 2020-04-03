defmodule Lumberjack.SourceTest do
  use ExUnit.Case

  @subject Lumberjack.Source

  doctest @subject

  test "events message pops out in stream" do
    stream = @subject.stream()

    @subject.log(%Lumberjack.Event{data: :test})

    assert [%Lumberjack.Event{data: :test}] = Enum.to_list(Stream.take(stream, 1))
  end
end
