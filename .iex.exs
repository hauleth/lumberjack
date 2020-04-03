require Logger

defmodule TestLogger do
  def start do
    {:ok, socket} = :gen_udp.open(0)

    {:ok, _pid} = Task.start(__MODULE__, :loop, [&:logger.log/2])

    {:ok, _pid} =
      Task.start(__MODULE__, :loop, [
        fn level, msg -> File.write!("log/example.log", ["[#{level}]", msg, ?\n], [:append]) end
      ])

    {:ok, _pid} =
      Task.start(__MODULE__, :loop, [
        fn level, msg -> :gen_udp.send(socket, {{127, 0, 0, 1}, 6666}, ["[#{level}]", msg]) end
      ])
  end

  def loop(f), do: loop(f, 0)

  defp loop(f, n) do
    f.(pick_level(), "Message #{n}")

    Process.sleep(Enum.random(200..2000))

    loop(f, n + 1)
  end

  defp pick_level, do: pick_level(Enum.random(0..159))

  defp pick_level(n) when n in 0..39, do: :debug
  defp pick_level(n) when n in 40..79, do: :info
  defp pick_level(n) when n in 80..119, do: :notice
  defp pick_level(n) when n in 120..134, do: :warning
  defp pick_level(n) when n in 135..149, do: :error
  defp pick_level(n) when n in 150..154, do: :critical
  defp pick_level(n) when n in 155..158, do: :alert
  defp pick_level(_), do: :emergency
end
