defmodule Trigger.MixProject do
  use Mix.Project

  def project do
    [
      app: :trigger,
      version: "1.0.0",
      elixir: "~> 1.5",
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :dev],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        ignore_warnings: ".dialyzer_ignore.exs",
        flags: [:error_handling, :underspecs, :unmatched_returns, :unknown],
      ],
    ]
  end

  def application do
    [extra_applications: []]
  end

  defp deps do
    [
      {:credo, "~> 1.5.0", only: [:dev], runtime: false},
      {:dialyxir, "~> 1.1.0", only: [:dev], runtime: false},
      {:excoveralls, "~> 0.14.1", only: [:dev], runtime: false},
    ]
  end
end
