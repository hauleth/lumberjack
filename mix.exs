defmodule Lumberjack.MixProject do
  use Mix.Project

  def project do
    [
      app: :lumberjack,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Lumberjack.Application, []},
      env: [
        sources: [Lumberjack.Sources.Logger]
      ]
    ]
  end

  defp package do
    [
      description: "Web based log viewer for Elixir applications",
      licenses: ~w[MPL-2.0],
      links: %{
        "GitHub" => "https://github.com/hauleth/lumberjack"
      }
    ]
  end

  defp docs do
    [
      groups_for_modules: [
        Sources: ~r/^Lumberjack\.Sources\./,
        Parsers: ~r/^Lumberjack\.Parsers\./
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.0"},
      {:file_system, "~> 0.2 or ~> 1.0"},

      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
