defmodule EctographTest.Schemas.Author do
  use Ecto.Schema

  @test_data [
    %{
      id: 1,
      uuid: Ecto.UUID.generate(),
      name: "Lucius Annaeus Seneca",
      info: %{
        born: "4 BC, Córdoba, Spain",
        died: "65 AD, Rome, Italy"
      },
    },
    %{
      id: 2,
      uuid: Ecto.UUID.generate(),
      name: "Marcus Aurelius",
      info: %{
        born: "April 26, 121 AD, Rome, Italy",
        died: "March 17, 180 AD"
      },
    },
  ]

  def test_data do
    @test_data
  end


  schema "author" do
    field :uuid, Ecto.UUID

    field :name, :string
    field :info, :map, default: %{}

    has_many :quotes, EctographTest.Schema.Quote
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
      }
    )
  end

end
