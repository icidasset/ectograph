defmodule Ectograph.Mixfile do
  use Mix.Project

  def project do
    [app: :ectograph,
     version: "0.0.1",
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
      ],
    ]
  end


  defp package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Steven Vandevelde"],
      links: %{"GitHub" => "https://github.com/icidasset/ectograph"}
    ]
  end


  # Dependencies
  #
  defp deps do
    [
      { :ecto, "~> 1.1.3" },
      { :graphql, "~> 0.1.2" },
    ]
  end


  # Specifies which paths to compile per environment
  #
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]
end
