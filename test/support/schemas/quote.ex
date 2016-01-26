defmodule EctographTest.Schemas.Quote do
  use Ecto.Schema

  schema "quote" do
    field :quote, :string

    field :amount_of_changes, :integer
    field :rating, :float
    field :related_authors, { :array, :id }

    has_one :author, EctographTest.Schema.Author

    timestamps
  end

end
