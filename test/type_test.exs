defmodule EctographTest.Type do
  use ExUnit.Case

  doctest Ectograph.Type

  test "should be able to cast all types of a ecto schema" do
    Enum.each(
      EctographTest.Schemas.Quote.__schema__(:types),
      fn(t) ->
        ecto_type = elem(t, 1)
        graphql_cast = Ectograph.Type.cast(ecto_type)

        assert elem(graphql_cast, 0) == :ok
      end
    )
  end

end
