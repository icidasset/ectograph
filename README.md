__Ectograph is a set of utility functions for using [Ecto](https://github.com/elixir-lang/ecto) in combination with [graphql-elixir/graphql](https://github.com/graphql-elixir/graphql).__

```
{
  :ecto, "~> 2.0.2",
  :graphql, "~> 0.3.1"
}
```

Features:

- Map a Ecto.Type to a GraphQL.Type
- Map a Ecto.Schema to a GraphQL.Type.ObjectType
- Provide extra GraphQL types, such as DateTime
- Utilities to help build a GraphQL schema



### How to use

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

Ectograph.Schema.cast(Schemas.Quote)
# %GraphQL.Type.ObjectType{ name: "quotes", fields: %{ quote: %{ type: ... }, ... }}
```

##### Types

```elixir
Ectograph.Type.cast(:string)
# %GraphQL.Type.String{}

Ectograph.Type.cast({ :array, :integer })
# %GraphQL.Type.List{ ofType: :integer }
```


##### Utilities

```elixir
schema = %GraphQL.Schema{
  query: %GraphQL.Type.ObjectType{
    name: "Queries",
    description: "GraphQL Queries",
    fields: %{
      quotes: Ectograph.Definitions.build(Quote, :all, ~w()a),
      quote: Ectograph.Definitions.build(Quote, :get, ~w(id)a),
    },
  },
}

# BUILD FUNCTION:
# Quote   = Resolver module
# :get    = method on resolver that will be called
# ~w(id)a = List of fields that will be used as arguments

# NOTE:
# Either the resolver itself is an Ecto schema,
# or you define a function called 'ecto_schema' that
# returns the Ecto schema.
```

See the [integration tests](/test/integration_test.exs)
for a working example, and the docs for more info.

```elixir
# Adding extra arguments to a query
Ectograph.Definitions.extend_arguments(
  put_field_aka_definition_here,
  %{ extra_argument: %{ type: GraphQL.Type.String }}
)

# Adding extra fields to a query
Ectograph.Definitions.extend_type_fields(
  put_field_aka_definition_here,
  %{ extra_field: %{ type: GraphQL.Type.Int }}
)

# Adding associations
Ectograph.Definitions.add_association(
  put_field_aka_definition_here,
  Resolver,
  :association_name,
  :multiple # or :single (default = :single)
)
```



### Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add ectograph to your list of dependencies in `mix.exs`:

        def deps do
          [{:ectograph, "~> 0.1.2"}]
        end

  2. Ensure ectograph is started before your application:

        def application do
          [applications: [:ectograph]]
        end



### To do

Things that are missing or could be improved

- Embedded schemas
- Associations

Ecto types that still have to be implemented:

- binary
- [decimal](https://github.com/ericmj/decimal)
- date
- time
- _composite types_
