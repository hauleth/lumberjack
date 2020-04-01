# Lumberjack

Application for providing nice UI for logs, especially in development. The idea
is to allow for digesting data from different sources, not only Erlang Logger.

## Goals

The intended use case is to have single place to view logs from all components
of your application, so not only Erlang/Elixir logs, but for example also DB
logs.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `lumberjack` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:lumberjack, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/lumberjack](https://hexdocs.pm/lumberjack).

## Configuration

```elixir
config :lumberjack,
  sources: [
    Lumberjack.Sources.Logger,
    {Lumberjack.Sources.File, dirs: ["logs"]},
    {Lumberjack.Sources.Socket, type: :udp, port: 7777}
  ]
```

## TODO

- ~~Web UI via SSE or WebSockets (to be decided later, but I am in favour of SSE)~~
- Parsers for the incoming messages, so it will be possible to extract levels
  out of the messages incoming from external sources
- Fix bugs in file source (missing first message, missing messages on rotation)
- Filtering incoming messages
- Way to check metadata of the logged message

## License

[MPL-2.0](LICENSE)
