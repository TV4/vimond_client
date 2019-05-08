defmodule VimondClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :vimond_client,
      version: "0.2.0",
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
      {:httpotion, "~> 3.0"},
      {:jason, "~> 1.0"},
      {:timex, "~> 3.3"},
      {:mix_test_watch, "~> 0.5", only: :test, runtime: false},
      {:mox, "~> 0.4", only: :test}
    ]
  end
end
