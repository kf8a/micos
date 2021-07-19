defmodule MicosUi.MixProject do
  use Mix.Project

  def project do
    [
      app: :micos_ui,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {MicosUi.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # {:instrument, path: "../instrument"},
      {:instrument, git: "git@gitlab.com:kf8a/instrument.git"},
      {:phoenix, "~> 1.5"},
      {:phoenix_pubsub, "~> 2.0"},
			{:phoenix_ecto, "~> 4.0"},
      {:gen_stage, "~> 1.0"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:amqp, "~> 2.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:learn_kit, "~> 0.1.6"},
      {:benchee, "~> 1.0", only: :dev},
      {:httpoison, "~> 1.8"},
      {:ex_doc, "~> 0.24.2", only: :dev},
      {:phoenix_live_view, "~> 0.15.7"},
    ]
  end
end
