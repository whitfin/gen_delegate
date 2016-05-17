defmodule GenDelegate.Mixfile do
  use Mix.Project

  @url_docs "http://hexdocs.pm/gen_delegate"
  @url_github "https://github.com/zackehh/gen_delegate"

  def project do
    [
      app: :gen_delegate,
      name: "GenDelegate",
      description: "Easy delegation of internal function to a GenServer interface",
      package: %{
        files: [
          "lib",
          "mix.exs",
          "LICENSE",
          "README.md"
        ],
        licenses: [ "MIT" ],
        links: %{
          "Docs" => @url_docs,
          "GitHub" => @url_github
        },
        maintainers: [ "Isaac Whitfield" ]
      },
      version: "0.0.1",
      elixir: "~> 1.1",
      deps: deps,
      docs: [
        extras: [ "README.md" ],
        source_ref: "master",
        source_url: @url_github
      ],
      preferred_cli_env: [
        "docs": :docs
      ]
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
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
      # documentation
      { :earmark, "~> 0.2.1",  optional: true, only: :docs },
      { :ex_doc,  "~> 0.11.4", optional: true, only: :docs },
      # testing
      { :power_assert, "~> 0.0.8", optional: true, only: :test }
    ]
  end
end
