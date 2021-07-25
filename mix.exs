defmodule Trigger.MixProject do
  use Mix.Project

  @source_url "https://github.com/sega-yarkin/trigger"
  @version "1.0.0"

  def project do
    [
      app: :trigger,
      version: @version,
      elixir: "~> 1.5",
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :dev],
      dialyzer: dialyzer(),
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp deps do
    [
      {:credo, "~> 1.5.0", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14.1", only: :dev, runtime: false},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      ignore_warnings: ".dialyzer_ignore.exs",
      flags: [:error_handling, :underspecs, :unmatched_returns, :unknown],
    ]
  end

  defp description do
    "A simple way to sync between processes."
  end

  defp package do
    [
      files: ~w(mix.exs README.md LICENSE lib),
      licenses: ["MIT"],
      links: %{GitHub: @source_url},
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "Trigger",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/trigger",
      source_url: @source_url,
      extras: ["README.md"],
    ]
  end
end
