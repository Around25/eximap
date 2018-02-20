defmodule Eximap.Mixfile do
  use Mix.Project

  @version "0.1.0-dev"

  def project do
    [
      app: :eximap,
      version: @version,
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      package: package(),
      deps: deps(),
      description: "A simple library to interact with an IMAP server",

      # Docs
      name: "Eximap",
      source_url: "https://github.com/around25/eximap",
      homepage_url: "https://around25.com",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test],
      docs: docs()
    ]
  end

  defp package do
    [
      name: "eximap",
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Cosmin Harangus <cosmin@around25.com>"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/around25/eximap"},
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Eximap.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 0.8.8", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.7.4", only: [:dev, :test], runtime: false},
    ]
  end

  defp docs do
    [
      main: "README", # The main page in the docs
      extras: ["README.md", "DEVELOPER.md", "CONTRIBUTING.md", "CODE_OF_CONDUCT.md"]
    ]
  end
end
