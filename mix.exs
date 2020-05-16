defmodule ExTectonicdb.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_tectonicdb,
      version: "0.1.0",
      elixir: "~> 1.9",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
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
      {:dialyxir, "~> 1.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:jason, "~> 1.2"}
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

  defp description do
    "TectonicDB client library for reading/writing L2 order book data"
  end

  defp package do
    %{
      licenses: ["MIT"],
      maintainers: ["Yuri Koval'ov"],
      links: %{
        "GitHub Source" => "https://github.com/yurikoval/ex_tectonicdb",
        "TectonicDB" => "https://github.com/0b01/tectonicdb"
      }
    }
  end
end
