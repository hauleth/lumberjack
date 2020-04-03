# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Source do
  @moduledoc """
  Definition of the log message source
  """

  @supervisor __MODULE__.Supervisor

  @key __MODULE__

  @callback install(opts :: keyword()) :: :ok | {:error, term()}

  @doc """
  Dispatch log message
  """
  def log(event) do
    Lumberjack.Stream.dispatch(@key, &send(&1, event))
  end

  @doc false
  def child_spec(_opts),
    do: DynamicSupervisor.child_spec(strategy: :one_for_one, name: @supervisor)

  @doc false
  def start_child(child_spec), do: DynamicSupervisor.start_child(@supervisor, child_spec)

  @doc false
  def stream do
    Lumberjack.Stream.register(@key)

    Stream.resource(
      fn -> :ok end,
      fn _ ->
        receive do
          %Lumberjack.Event{} = msg -> {[msg], :ok}
        end
      end,
      fn _ -> :ok end
    )
  end

  # Install all sources defined in the application configuration
  @doc false
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
