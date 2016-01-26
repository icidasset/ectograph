# Ectograph

__WORK IN PROGRESS!__

Ectograph is a set of utility functions for using [Ecto](https://github.com/elixir-lang/ecto) in combination with GraphQL (specifically [this graphql library](https://github.com/joshprice/graphql-elixir) for Elixir).



## Features

- Map a Ecto.Type to a GraphQL.Type
- Map a Ecto.Schema to a GraphQL.Type.ObjectType
- Provide extra GraphQL types, such as DateTime



## How to use

```elixir

```



## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add ectograph to your list of dependencies in `mix.exs`:

        def deps do
          [{:ectograph, "~> 0.0.1"}]
        end

  2. Ensure ectograph is started before your application:

        def application do
          [applications: [:ectograph]]
        end
