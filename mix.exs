defmodule Ectograph.Mixfile do
  use Mix.Project

  def project do
    [app: :ectograph,
     description: "Ectograph is a set of utility functions for using Ecto in combination with GraphQL (joshprice/graphql-elixir)",
     version: "0.0.6",
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
        :ecto,
        :timex,
        :tzdata
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
      { :ecto, "~> 2.0.0-rc.5" },
      { :graphql, "~> 0.2.0" },
      { :timex, ">= 2.0.0" },

      { :earmark, "~> 0.2.1", only: :dev },
      { :ex_doc, "~> 0.11.4", only: :dev },
    ]
  end


  # Specifies which paths to compile per environment
  #
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
