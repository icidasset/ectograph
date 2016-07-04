defmodule Ectograph.Mixfile do
  use Mix.Project

  def project do
    [app: :ectograph,
     description: "Ectograph is a set of utility functions for using Ecto in combination with GraphQL",
     version: "0.2.0",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     package: package]
  end


  def application do
    [
      applications: [
        :ecto
      ],
    ]
  end


  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Steven Vandevelde"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/icidasset/ectograph"}
    ]
  end


  # Dependencies
  #
  defp deps do
    [
      { :ecto, "~> 2.0.2" },
      { :graphql, "~> 0.3.1" },

      { :earmark, "~> 0.2.1", only: :dev },
      { :ex_doc, "~> 0.12.0", only: :dev },
    ]
  end


  # Specifies which paths to compile per environment
  #
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
