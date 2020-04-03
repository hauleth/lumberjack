import Config

config :lumberjack,
  port: 4000,
  sources: [
    Lumberjack.Sources.Logger,
    {Lumberjack.Sources.File, dirs: ["log"], parsers: [Lumberjack.Parsers.Simple]},
    {Lumberjack.Sources.Socket, port: 6666, parsers: [Lumberjack.Parsers.Simple]}
  ]
