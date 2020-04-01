import Config

config :lumberjack,
  port: 4000,
  sources: [
    Lumberjack.Sources.Logger,
    {Lumberjack.Sources.File, dirs: ["log"]},
    {Lumberjack.Sources.Socket, port: 6666}
  ]
