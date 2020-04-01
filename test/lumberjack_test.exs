defmodule LumberjackTest do
  use ExUnit.Case
  doctest Lumberjack

  test "greets the world" do
    assert Lumberjack.hello() == :world
  end
end
