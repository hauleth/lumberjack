# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Lumberjack.Source,
      {Registry, keys: :duplicate, name: Lumberjack.Registry},
      {Plug.Cowboy, scheme: :http, port: 4000, plug: Lumberjack.Router}
    ]

    opts = [strategy: :one_for_one, name: Lumberjack.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, _pid} = ok ->
        Lumberjack.Source.install()
        ok

      err ->
        err
    end
  end
end
