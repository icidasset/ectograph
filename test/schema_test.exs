defmodule EctographTest.Schema do
  use ExUnit.Case

  doctest Ectograph.Type

  test "should be able to cast a Ecto schema to a GraphQL schema" do
    cast = Ectograph.Schema.cast_schema(
      EctographTest.Schemas.Quote,
      :ecto_to_graphql
    )

    assert elem(cast, 0) == :ok
  end

end
