defmodule NeuralBridge.MixProject do
  use Mix.Project

  def project do
    [
      app: :neural_bridge,
      version: "0.0.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      ddocs: [extras: ["README.md"], main: "readme", source_ref: "v0.0.1"],
      source_url: "https://github.com/lorenzosinisi/neural_bridge",
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  defp description do
    """
    Expert system in Elixir - a bridge brain-computer-machine to transfer knowledge from an expert to an algorithm

    This system implements a rules based mechanism that mimics the human interaction
    with an expert of a specific domain.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Lorenzo Sinisi"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/lorenzosinisi/retex"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {NeuralBridge.Application, []}
    ]
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: ["Lorenzo Sinisi"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/lorenzosinisi/neural_bridge"}
    ]
  end

  defp deps do
    [
      {:sanskrit, git: "https://github.com/lorenzosinisi/sanskrit"},
      {:retex, "~> 0.1.9"},
      {:decimal, "~> 2.0"}
    ]
  end
end
