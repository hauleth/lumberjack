# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    port = Application.get_env(:lumberjack, :port)

    children = [
      Lumberjack.Stream,
      Lumberjack.Source
    ] ++ server(port)

    opts = [strategy: :one_for_one, name: Lumberjack.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, _pid} = ok ->
        Lumberjack.Source.install()
        ok

      err ->
        err
    end
  end

  defp server(nil), do: []
  defp server(port) when is_integer(port) do
    [
      {Plug.Cowboy, scheme: :http, port: 4000, plug: Lumberjack.Router}
    ]
  end
end
