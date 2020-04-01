# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Sources.Logger do
  @behaviour Lumberjack.Source

  def install(_opts) do
    :ok = :logger.add_handler(Lumberjack, Lumberjack.Sources.Logger, %{})

    :ok
  end

  def log(event, %{formatter: {fmod, opts}}) do
    data = to_string(fmod.format(event, opts))

    Registry.dispatch(Lumberjack.Registry, :logs, fn entries ->
      for {pid, _} <- entries do
        send(pid, {:log, data})
      end
    end)
  end
end
