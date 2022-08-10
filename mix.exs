defmodule BroadwayEctoJob.Producer.MixProject do
  use Mix.Project

  def project do
    [
      app: :broadway_ecto_job,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:broadway, "~> 1.0.3"},
      {:gen_stage, "~> 1.0", override: true},
      {:ecto_job, "~> 3.0"}
    ]
  end
end
