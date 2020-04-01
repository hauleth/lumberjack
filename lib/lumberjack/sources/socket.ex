# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Sources.Socket do
  use GenServer

  @behaviour Lumberjack.Source

  @doc false
  def install(opts) do
    type = Keyword.get(opts, :type, :udp)
    port = Keyword.fetch!(opts, :port)

    {:ok, _pid} = Lumberjack.Source.start_child({__MODULE__, %{type: type, port: port}})

    :ok
  end

  @doc false
  def start_link(opts), do: GenServer.start_link(__MODULE__, opts)

  @doc false
  def init(%{type: type, port: port}) do
    {:ok, socket} = socket(type, port)

    {:ok, %{socket: socket, name: name(type, port)}}
  end

  def handle_info({:udp, socket, _ip, _port, data}, %{socket: socket, name: name} = state) do
    Lumberjack.Source.log(name, :info, data)

    {:noreply, state}
  end

  defp socket(:udp, port), do: :gen_udp.open(port, [:binary])

  defp name(:udp, port), do: "UDP #{port}"
  defp name(:tcp, port), do: "TCP #{port}"
end
