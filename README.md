# Ectograph

Ectograph is a set of utility functions for using [Ecto](https://github.com/elixir-lang/ecto) in combination with GraphQL (specifically [this graphql library](https://github.com/joshprice/graphql-elixir) for Elixir).

```
defp deps do
  [
    { :ecto, "~> 2.0.0-rc.5" },
    { :graphql, "~> 0.2.0" }
  ]
end
```



## Features

- Map a Ecto.Type to a GraphQL.Type
- Map a Ecto.Schema to a GraphQL.Type.ObjectType
- Map a GraphQL.Type to a Ecto.Type
- Provide extra GraphQL types, such as DateTime



## How to use

##### Schemas

```elixir
defmodule Schemas.Quote do
  use Ecto.Schema

  schema "quotes" do
    field :quote, :string
    field :author, :string

    timestamps
  end

end

Ectograph.Schema.cast_schema(Schemas.Quote, :ecto_to_graphql)
# %GraphQL.Type.ObjectType{ name: "quotes", fields: %{ quote: %{ type: ... }, ... }}
```

##### Types

```elixir
Ectograph.Type.cast_type(:string, :ecto_to_graphql)
# %GraphQL.Type.String{}

Ectograph.Type.cast_type({ :array, :integer }, :ecto_to_graphql)
# %GraphQL.Type.List{ ofType: :integer }

Ectograph.Type.cast_type(%GraphQL.Type.String{}, :graphql_to_ecto)
# :string

Ectograph.Type.cast_type(%GraphQL.Type.List{ ofType: :integer }, :graphql_to_ecto)
# { :array, :integer }
```

##### Example

You can find a working example at [https://github.com/icidasset/key_maps](https://github.com/icidasset/key_maps).  
The crucial bit is located at `lib/graphql/definitions.ex`.



## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add ectograph to your list of dependencies in `mix.exs`:

        def deps do
          [{:ectograph, "~> 0.0.8"}]
        end

  2. Ensure ectograph is started before your application:

        def application do
          [applications: [:ectograph]]
        end



## To do

Missing features:

- Casting a GraphQL schema to an Ecto schema (not sure how to implement this)

Things I haven't tried yet:

- Associations
- Embedded schemas

Ecto types that still have to be implemented:

- binary
- [decimal](https://github.com/ericmj/decimal)
- date
- time
- _composite types_
