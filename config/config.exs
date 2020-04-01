import Config

config :lumberjack,
  sources: [
    Lumberjack.Sources.Logger,
    {Lumberjack.Sources.File, dirs: ["log"]},
    {Lumberjack.Sources.Socket, port: 6666}
  ]
