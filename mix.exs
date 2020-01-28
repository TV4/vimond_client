defmodule Vimond.Client.MixProject do
  use Mix.Project

  def project do
    [
      app: :vimond_client,
      version: "0.3.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: ["test.watch": :test]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:plug, "~> 1.6"},
      {:jason, "~> 1.0"},
      {:calendar, "~> 1.0"},
      {:httpoison, "~> 1.6"},
      {:mix_test_watch, "~> 1.0", only: :test, runtime: false},
      {:mox, "~> 0.4", only: :test}
    ]
  end
end
