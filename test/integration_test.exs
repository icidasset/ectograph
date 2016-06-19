defmodule EctographTest.Schema do
  use ExUnit.Case

  doctest Ectograph.Type

  alias EctographTest.Schemas.{Author, Quote}
  alias Ectograph.{Definitions}


  setup_all do
    create_args = ~w(quote revision rating related_authors)a

    extra_arg = %{ extra_arg: %{ type: %GraphQL.Type.String{} }}
    extra_fld = %{ extra_fld: %{ type: %GraphQL.Type.String{} }}

    add_author = fn(d) ->
      Definitions.add_association(d, Author, :author)
    end

    schema = %GraphQL.Schema{
      query: %GraphQL.Type.ObjectType{
        name: "Queries",
        description: "GraphQL Queries",
        fields: %{
          quotes:   Definitions.build(Quote, :all, ~w()a    ) |> add_author.(),
          quote:    Definitions.build(Quote, :get, ~w(id)a  ) |> add_author.(),
        },
      },

      mutation: %GraphQL.Type.ObjectType{
        name: "Mutations",
        description: "GraphQL Mutations",
        fields: %{
          createQuote: (
            Definitions.build(Quote, :create, create_args)
            |> Definitions.extend_arguments(extra_arg)
            |> Definitions.extend_type_fields(extra_fld)
          ),
        },
      },
    }

    # context
    { :ok, %{
      schema: schema,
    }}
  end


  test "should be able to get quotes", context do
    query = ~S[
      query _ {
        quotes {
          id, revision, rating, quote,
          related_authors, inserted_at, updated_at
        }
      }]

    # execute
    { state, result } = GraphQL.execute(context.schema, query)

    quotes = result.data["quotes"]
    first_quote = List.first(quotes)

    # assertions
    assert state == :ok
    assert is_binary(first_quote["inserted_at"])
    assert first_quote["id"] == "1"
    assert first_quote["revision"] == 1
    assert first_quote["rating"] == 0.75
    assert first_quote["quote"] == List.first(Quote.test_data).quote
    assert List.first(first_quote["related_authors"]) == 20
  end


  test "should be able to get a quote", context do
    query = ~S[
      query _ ($id: Int) {
        quote (id: $id) {
          id, revision, rating, quote,
          related_authors, inserted_at, updated_at
        }
      }]

    # execute
    { state, result } = GraphQL.execute(
      context.schema,
      query,
      %{ id: 2 }
    )

    q = result.data["quote"]

    # assertions
    assert state == :ok
    assert is_binary(q["inserted_at"])
    assert q["id"] == "2"
    assert q["revision"] == 2
    assert q["rating"] == 0.25
    assert q["quote"] == "One must steer, not talk."
    assert List.first(q["related_authors"]) == 30
  end


  test "should be able to create a quote", context do
    query = ~S[
      mutation _ (
        $revision: Int,
        $rating: Int,
        $quote: String,
        $related_authors: Array,
        $extra_arg: String
      ) {
        createQuote (
          revision: $revision,
          rating: $rating,
          quote: $quote,
          related_authors: $related_authors,
          extra_arg: $extra_arg
        ) {
          id, revision, rating, quote,
          related_authors, inserted_at, updated_at,
          extra_fld
        }
      }]

    # execute
    { state, result } = GraphQL.execute(
      context.schema,
      query,
      %{
        revision: 10,
        rating: 1,
        quote: "Integration",
        related_authors: [20],
        extra_arg: "HI FROM TEST",
      }
    )

    q = result.data["createQuote"]

    # assertions
    assert state == :ok
    assert is_binary(q["inserted_at"])
    assert q["id"] == "30"
    assert q["revision"] == 10
    assert q["rating"] == 1
    assert q["quote"] == "Integration"
    assert q["extra_fld"] == "HI FROM TEST"
    assert List.first(q["related_authors"]) == 20
  end

end
