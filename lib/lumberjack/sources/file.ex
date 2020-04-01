# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Sources.File do
  use GenServer

  @behaviour Lumberjack.Source

  def install(opts) do
    dirs = Keyword.fetch!(opts, :dirs)
    {:ok, _pid} = Lumberjack.Source.start_child({__MODULE__, dirs})

    :ok
  end

  def start_link(dirs) do
    GenServer.start_link(__MODULE__, dirs)
  end

  def init(dirs) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: dirs)
    FileSystem.subscribe(watcher_pid)

    {:ok, %{watcher_pid: watcher_pid, streams: %{}}}
  end

  def handle_info(
        {:file_event, wpid, {path, _events}},
        %{watcher_pid: wpid, streams: streams} = state
      ) do
    stream =
      Map.get_lazy(streams, path, fn ->
        IO.puts("Opening file #{path}")
        file = File.open!(path, ~w[read]a)
        :file.position(file, :eof)

        file
      end)

    data = String.split(IO.read(stream, :all), ~r/\n+/, trim: true)

    Registry.dispatch(Lumberjack.Registry, :logs, fn entries ->
      for {pid, _} <- entries do
        send(pid, {:log, data})
      end
    end)

    {:noreply, %{state | streams: Map.put(streams, path, stream)}}
  end

  def handle_info({:file_event, wpid, :stop}, %{watcher_pid: wpid} = state) do
    {:stop, :watcher_stopped, state}
  end
end
