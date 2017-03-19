defmodule Vivid.Mixfile do
  use Mix.Project

  def project do
    [app: :vivid,
     version: "0.3.0",
     description: description(),
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  def description do
    """
    Simple 2D rendering graphics rendering library.
    """
  end

  def package do
    [
      maintainers: [ "James Harton <james@messagerocket.co>" ],
      licenses: [ "MIT" ],
      links: %{
        "Source" => "https://github.com/jamesotron/vivid.ex"
      }
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
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
