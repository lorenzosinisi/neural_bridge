defmodule NeuralBridge.MixProject do
  use Mix.Project

  def project do
    [
      app: :neural_bridge,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NeuralBridge.Application, []}
    ]
  end

  defp deps do
    [
      {:sanskrit, git: "https://github.com/lorenzosinisi/sanskrit"},
      {:retex, git: "https://github.com/lorenzosinisi/retex"}
    ]
  end
end
