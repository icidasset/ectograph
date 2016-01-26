defmodule EctographTest.Schemas.Author do
  use Ecto.Schema

  schema "author" do
    field :uuid, Ecto.UUID

    field :name, :string
    field :info, :map

    timestamps
  end

end
