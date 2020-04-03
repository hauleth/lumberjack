defmodule Lumberjack.Parsers.SimpleTest do
  use ExUnit.Case, async: true

  @subject Lumberjack.Parsers.Simple

  doctest @subject

  test "plain message is errors (aka pass through)" do
    assert :error == @subject.parse("Foo")
  end

  test "level is parsed" do
    assert {:ok, parsed} = @subject.parse("[info] Foo")
    assert parsed.data.level == :info
  end

  test "when invalid level, errors" do
    assert :error == @subject.parse("[iinfo] Foo")
    assert :error == @subject.parse("[ info] Foo")
  end

  test "date time is parsed" do
    assert {:ok, parsed} = @subject.parse("2016-04-16T12:34:56.7890Z [info] Foo")
    assert parsed.timestamp == 1460810096789000
  end

  test "fails on incorrect DT" do
    assert :error == @subject.parse("2016-04-16T12:34:5 [info] Foo")
  end

  test "trims message" do
    assert {:ok, parsed} = @subject.parse("[info] Foo  ")
    assert parsed.data.msg == "Foo"
  end
end
