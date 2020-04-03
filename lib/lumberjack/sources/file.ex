# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Sources.File do
  use GenServer

  @behaviour Lumberjack.Source

  @doc false
  def install(opts) do
    dirs = Keyword.fetch!(opts, :dirs)
    parsers = Keyword.get(opts, :parsers, [])

    {:ok, _pid} = Lumberjack.Source.start_child({__MODULE__, %{
      dirs: dirs,
      parsers: parsers
    }})

    :ok
  end

  @doc false
  def start_link(args), do: GenServer.start_link(__MODULE__, args)

  @doc false
  def init(%{dirs: dirs, parsers: parsers}) do
    {:ok, watcher_pid} = FileSystem.start_link(dirs: dirs)
    FileSystem.subscribe(watcher_pid)

    {:ok, %{watcher_pid: watcher_pid, streams: %{}, parsers: parsers}}
  end

  @doc false
  def handle_info(
        {:file_event, wpid, {path, _events}},
        %{watcher_pid: wpid, streams: streams, parsers: parsers} = state
      ) do
    stream =
      Map.get_lazy(streams, path, fn ->
        file = File.open!(path, ~w[read]a)
        :file.position(file, :eof)

        file
      end)

    data = String.split(IO.read(stream, :all), ~r/\n+/, trim: true)

    for entry <- data do
      parsed =
        entry
        |> Lumberjack.Parser.parse(parsers)
        |> struct(source: path)

      Lumberjack.Source.log(parsed)
    end

    {:noreply, %{state | streams: Map.put(streams, path, stream)}}
  end

  def handle_info({:file_event, wpid, :stop}, %{watcher_pid: wpid} = state) do
    {:stop, :watcher_stopped, state}
  end
end
