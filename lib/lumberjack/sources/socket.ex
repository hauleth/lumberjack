# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Sources.Socket do
  use GenServer

  @behaviour Lumberjack.Source

  def install(opts) do
    type = Keyword.get(opts, :type, :udp)
    port = Keyword.fetch!(opts, :port)

    {:ok, _pid} = Lumberjack.Source.start_child({__MODULE__, %{type: type, port: port}})

    :ok
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(%{type: type, port: port}) do
    {:ok, socket} = socket(type, port)

    {:ok, socket}
  end

  def handle_info({:udp, socket, _ip, _port, data}, socket) do
    Registry.dispatch(Lumberjack.Registry, :logs, fn entries ->
      for {pid, _} <- entries do
        send(pid, {:log, data})
      end
    end)

    {:noreply, socket}
  end

  defp socket(:udp, port), do: :gen_udp.open(port, [:binary])
end
