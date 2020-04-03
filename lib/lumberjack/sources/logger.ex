# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

defmodule Lumberjack.Sources.Logger do
  @default_formatter {:logger_formatter,
                      %{
                        single_line: false,
                        template: [:msg]
                      }}

  @moduledoc """
  Extract messages from Erlang logger.

  ## Options

  - `formatter` - how to format message before sending it to the UI.
    It should be tuple in form of `{format_module, options_map}`. Defaults
    to `#{inspect(@default_formatter)}`
  """
  @behaviour Lumberjack.Source

  @doc false
  def install(opts) do
    formatter = Keyword.get(opts, :formatter, @default_formatter)

    :ok =
      :logger.add_handler(Lumberjack, Lumberjack.Sources.Logger, %{
        formatter: formatter
      })

    :ok
  end

  @doc false
  def log(%{level: level, meta: meta} = event, %{formatter: {fmod, opts}}) do
    {ts, meta} = Map.pop!(meta, :time)

    msg =
      event
      |> fmod.format(opts)
      |> to_string()

    encoded = encode(meta)

    Lumberjack.Source.log(%Lumberjack.Event{
      timestamp: ts,
      source: :logger,
      data: %{
        msg: msg,
        level: level,
        meta: encoded
      }
    })
  end

  defp encode(meta) when is_map(meta), do: Map.new(meta, &encode_keys/1)

  defp encode(data) when is_binary(data) when is_number(data) when is_atom(data),
    do: data

  defp encode(list) when is_list(list) do
    cond do
      Keyword.keyword?(list) -> Map.new(list, &encode_keys/1)
      List.ascii_printable?(list) -> List.to_string(list)
      true -> for elem <- list, do: encode(elem)
    end
  end

  defp encode(data), do: inspect(data)

  defp encode_keys({key, value}), do: {to_string(key), encode(value)}
end
