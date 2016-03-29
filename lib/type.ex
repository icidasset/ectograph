defmodule Ectograph.Type do

  @map %{
    :array      => %{ is_built_in: true, name: "List" },
    :boolean    => %{ is_built_in: true, name: "Boolean" },
    :datetime   => %{ is_built_in: false, name: "DateTime" },
    :float      => %{ is_built_in: true, name: "Float" },
    :id         => %{ is_built_in: true, name: "ID" },
    :integer    => %{ is_built_in: true, name: "Int" },
    :map        => %{ is_built_in: true, name: "JSON" },
    :string     => %{ is_built_in: true, name: "String" },
    :uuid       => %{ is_built_in: true, name: "String" },
  }


  # More info: https://github.com/elixir-lang/ecto/blob/db1f9ccdcc01f5abffcab0b5e0732eeecd93aa19/lib/ecto/schema.ex#L145
  @custom_ecto_types %{
    :date       => "Date",
    :datetime   => "DateTime",
    :time       => "Time",
    :uuid       => "UUID",
  }


  defp get_graphql_struct_attributes(base_ecto_type, arg) do
    case base_ecto_type do
      :array    -> %{ ofType: elem(arg, 1) }

      _         -> %{}
    end
  end


  defp get_base_ecto_type(arg) do
    ecto_type = Ecto.Type.type(arg)

    cond do
      is_tuple(ecto_type) -> elem(ecto_type, 0)
      true -> ecto_type
    end
  end


  defp get_ecto_type(base_ecto_type, arg) do
    t = case base_ecto_type do
      :array    -> { :array, Map.from_struct(arg)[:ofType] }

      _         -> nil
    end

    unless t do
      t = Map.get(@custom_ecto_types, base_ecto_type)
      t = if t, do: Module.concat(Ecto, t), else: base_ecto_type
    end

    t
  end


  @doc """
    Cast a Ecto type (atom | tuple | module) to a GraphQL type (struct).

    @return { :ok | :error, value }
  """
  def cast_type(arg, :ecto_to_graphql) do
    base_ecto_type = get_base_ecto_type(arg)
    graphql_type_def = @map[base_ecto_type]

    case graphql_type_def do
      nil ->
        { :error }

      _ ->
        graph_module = Module.concat([
          (if graphql_type_def.is_built_in,
            do: GraphQL.Type,
            else: Ectograph.Type.Custom.GraphQL),
          graphql_type_def.name
        ])

        map = struct(
          graph_module,
          get_graphql_struct_attributes(base_ecto_type, arg)
        )

        { :ok, map }
    end
  end


  @doc """
    Cast a GraphQL type (struct) to a Ecto type (atom | tuple).

    @return { :ok | :error, value }
  """
  def cast_type(arg, :graphql_to_ecto) do
    graphql_type = arg.__struct__
      |> Module.split
      |> List.last

    base_ecto_type = @map
      |> Map.to_list
      |> Enum.find(fn(m) -> elem(m, 1)[:name] == graphql_type end)
      |> elem(0)

    case base_ecto_type do
      nil -> { :error }
      _   -> { :ok, get_ecto_type(base_ecto_type, arg) }
    end
  end



  # DateTime type for GraphQL.
  #
  defmodule Custom.GraphQL.DateTime do
    defstruct name: "DateTime", description:
      """
      The `DateTime` type represents a datetime value in the UTC timezone.
      """
  end

  defimpl GraphQL.Types, for: Custom.GraphQL.DateTime do
    def parse_value(_, value), do: DateFormat.parse!(value, "{ISO}")
    def serialize(_, value), do: DateFormat.format!(value, "{ISOz}")
  end

end
