defmodule EctographTest.Schemas.Quote do
  use Ecto.Schema

  @epoch (
    {{ 1970, 1, 1 }, { 0, 0, 0 }}
    |> :calendar.datetime_to_gregorian_seconds
  )

  @now (
    :os.system_time(:seconds)
    |> +(@epoch)
    |> :calendar.gregorian_seconds_to_datetime
    |> Ecto.DateTime.from_erl
  )

  @test_data [
    %{
      id: 1,
      quote: "The secret of all victory lies in the organization of the non-obvious.",
      revision: 1,
      rating: 0.75,
      author_id: 2,
      related_authors: [20],
      inserted_at: @now,
      updated_at: @now,
    },
    %{
      id: 2,
      quote: "One must steer, not talk.",
      revision: 2,
      rating: 0.25,
      related_authors: [30],
      inserted_at: @now,
      updated_at: @now,
    },
  ]

  def test_data do
    @test_data
  end


  schema "quote" do
    field :quote, :string

    field :revision, :integer, default: 1
    field :rating, :float, default: 0.5
    field :related_authors, { :array, :integer }, default: []

    belongs_to :author, EctographTest.Schema.Author

    timestamps
  end


  def all(_, _, _), do: all
  def all, do: @test_data

  def get(params, _, _), do: get_by_id(params.id)
  def get_by_id(id), do: Enum.find(@test_data, &(&1.id == id))

  def create(params, _, _) do
    Map.merge(
      params,
      %{
        id: 30,
        inserted_at: @now,
        updated_at: @now,
        extra_fld: params.extra_arg,
      }
    )
  end

end
