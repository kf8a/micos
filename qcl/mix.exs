defmodule Qcl.MixProject do
  use Mix.Project

  def project do
    [
      app: :qcl,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Qcl.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nimble_parsec, "~> 0.2"},
      {:nimble_csv, "~> 0.3"},
      {:circuits_uart, "~> 1.3"},
    ]
  end
end
