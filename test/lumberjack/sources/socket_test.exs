defmodule Lumberjack.Sources.SocketTest do
  use ExUnit.Case

  @subject Lumberjack.Sources.Socket

  doctest @subject

  describe "udp" do
    test "messages sent to socket pop out in stream" do
      stream = Lumberjack.stream()

      send_udp("Hello")

      assert [%Lumberjack.Event{data: %{msg: "Hello"}}] = Enum.to_list(Stream.take(stream, 1))
    end
  end

  defp send_udp(msg) do
    {:ok, socket} = :gen_udp.open(0)
    dest = {{127, 0, 0, 1}, 6666}

    :gen_udp.send(socket, dest, msg)
  end
end
