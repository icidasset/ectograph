defmodule EctographTest do
  use ExUnit.Case

  doctest Ectograph.Type

  test "should be able to cast all types of a ecto schema (and back)" do
    Enum.each(
      EctographTest.Schemas.Quote.__schema__(:types),
      fn(t) ->
        ecto_type = elem(t, 1)
          |> Ecto.Type.type

        graphql_cast = ecto_type
          |> Ectograph.Type.cast_type(:ecto_to_graphql)

        assert elem(graphql_cast, 0) == :ok

        ecto_cast = elem(graphql_cast, 1)
          |> Ectograph.Type.cast_type(:graphql_to_ecto)

        assert elem(ecto_cast, 0) == :ok
        assert elem(ecto_cast, 1) == ecto_type # should match the initial value
      end
    )
  end

end
