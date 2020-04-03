defmodule Lumberjack.Parser do
  @callback parse(input :: binary()) :: {:ok, Lumberjack.Event.t()} | :error

  def parse(data, parsers) do
    return =
      Enum.reduce_while(parsers, :error, fn parser, _ ->
        case parser.parse(data) do
          {:ok, parsed} -> {:halt, {:ok, parsed}}
          :error -> {:cont, :error}
        end
      end)

    case return do
      {:ok, data} -> data
      _ -> %Lumberjack.Event{
          timestamp: :logger.timestamp(),
          data: %{
            msg: data,
            level: :notice,
            meta: %{}
          }
      }
    end
  end
end
