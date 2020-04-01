# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Source do
  @supervisor __MODULE__.Supervisor

  def child_spec(_opts) do
    DynamicSupervisor.child_spec(strategy: :one_for_one, name: @supervisor)
  end

  def start_child(child_spec) do
    DynamicSupervisor.start_child(@supervisor, child_spec)
  end

  @callback install(opts :: keyword()) :: :ok | {:error, term()}

  def install do
    :lumberjack
    |> Application.fetch_env!(:sources)
    |> Enum.each(&install_source/1)
  end

  defp install_source({mod, opts}) when is_atom(mod) do
    :ok = mod.install(opts)
  end

  defp install_source(mod) when is_atom(mod) do
    :ok = mod.install([])
  end
end
