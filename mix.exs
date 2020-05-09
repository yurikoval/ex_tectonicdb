defmodule ExTectonicdb.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_tectonicdb,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp dialyzer do
    [
      plt_file: {:no_warn, "_build/#{Mix.env()}/dialyzer.plt"},
      flags: [
        :unmatched_returns,
        :error_handling,
        :race_conditions,
        :underspecs,
        :no_opaque
      ],
      plt_add_deps: :transitive,
      ignore_warnings: "dialyzer.ignore-warnings"
    ]
  end
end
