defmodule Instrument.MixProject do
  use Mix.Project

  def project do
    [
      app: :instrument,
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
      mod: {Instrument.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:amqp, "~> 1.2"},
      {:qcl, path: "../qcl"},
      {:licor, github: "kf8a/licor"},
    ]
  end
end
