# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Stream do
  @moduledoc false

  @name __MODULE__.Registry

  def child_spec(_opts), do: Registry.child_spec(keys: :duplicate, name: @name)

  def register(key), do: Registry.register(@name, key, [])

  def dispatch(key, fun) do
    Registry.dispatch(@name, key, fn entries ->
      for {pid, _} <- entries, do: fun.(pid)
    end)
  end
end
