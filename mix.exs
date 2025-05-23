defmodule Vivid.Mixfile do
  @moduledoc false
  use Mix.Project

  @version "0.4.4"

  def project do
    [
      app: :vivid,
      version: @version,
      description: description(),
      elixir: "~> 1.3",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps(),
      source_url: "https://harton.dev/james/vivid",
      homepage_url: "https://harton.dev/james/vivid",
      docs: [
        source_ref: "v#{@version}",
        main: "Vivid",
        canonical: "http://hexdocs.pm/vivid",
        source_url: "https://harton.dev/james/vivid",
        extras: ["guides/getting-started.md", "README.md", "CHANGELOG.md"]
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [extra_applications: [:logger]]
  end

  def description do
    """
    Simple 2D rendering graphics rendering library.
    """
  end

  def package do
    [
      maintainers: ["James Harton <james@harton.nz>"],
      licenses: ["MIT"],
      links: %{
        "Source" => "https://harton.dev/james/vivid",
        "GitHub" => "https://github.com/jimsynz/vivid",
        "Changelog" => "https://docs.harton.nz/james/vivid/changelog.html",
        "Sponsor" => "https://github.com/sponsors/jimsynz"
      },
      source_url: "https://harton.dev/james/vivid"
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    opts = [only: ~w[dev test]a, runtime: false]

    [
      {:credo, "~> 1.7", opts},
      {:dialyxir, "~> 1.3", opts},
      {:doctor, "~> 0.22", opts},
      {:ex_check, "~> 0.16", opts},
      {:ex_doc, ">= 0.0.0", opts},
      {:git_ops, "~> 2.6", opts},
      {:mix_audit, "~> 2.1", opts}
    ]
  end
end
