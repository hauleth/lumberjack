defmodule Lumberjack.Parsers.Simple do
  @regex ~r/^(?<date>\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(.\d+)?Z)?\s*(\[(?<level>\w+)\])?(?<msg>.*)$/m

  def parse(input) do
    with %{"msg" => msg} = matches <- Regex.named_captures(@regex, input),
         {:ok, ts} <- date(matches),
         {:ok, level} <- level(matches)
    do
      {:ok, %Lumberjack.Event{
        timestamp: ts,
        data: %{
          msg: String.trim(msg),
          level: level,
          meta: %{}
        }
      }}
    else
      _ -> :error
    end
  end

  defp date(%{"date" => str}) when is_binary(str) do
    with {:ok, datetime, _} <- DateTime.from_iso8601(str) do
      {:ok, DateTime.to_unix(datetime, :microsecond)}
    else
      _ -> {:ok, :logger.timestamp()}
    end
  end

  defp date(_), do: :logger.timestamp()

  defp level(%{"level" => level}) when is_binary(level), do: do_level(String.downcase(level))
  defp level(_), do: :error

  defp do_level("debug"), do: {:ok, :debug}
  defp do_level("info"), do: {:ok, :info}
  defp do_level("notice"), do: {:ok, :notice}
  defp do_level("warning"), do: {:ok, :warning}
  defp do_level("warn"), do: {:ok, :warning}
  defp do_level("error"), do: {:ok, :error}
  defp do_level("critical"), do: {:ok, :critical}
  defp do_level("alert"), do: {:ok, :alert}
  defp do_level("emergency"), do: {:ok, :emergency}


  defp do_level(_), do: :error
end
