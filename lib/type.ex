defmodule Ectograph.Type do

  @map %{
    :array      => %{ is_built_in: true, name: "List" },
    :boolean    => %{ is_built_in: true, name: "Boolean" },
    :datetime   => %{ is_built_in: false, name: "DateTime" },
    :float      => %{ is_built_in: true, name: "Float" },
    :id         => %{ is_built_in: true, name: "ID" },
    :integer    => %{ is_built_in: true, name: "Int" },
    :map        => %{ is_built_in: true, name: "JSON" },

    :string     => %{ is_built_in: true, name: "String", closest: true },
    :uuid       => %{ is_built_in: true, name: "String" },
    :binary_id  => %{ is_built_in: true, name: "String" },
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
      :array ->
        array_item_type = cast_type(
          elem(arg, 1),
          :ecto_to_graphql
        )

        if elem(array_item_type, 0) === :ok do
          %{ ofType: elem(array_item_type, 1) }
        else
          nil
        end

      _ ->
        %{}
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
      :array ->
        array_item_type = cast_type(
          Map.from_struct(arg)[:ofType],
          :graphql_to_ecto
        )

        if elem(array_item_type, 0) === :ok do
          { :array, elem(array_item_type, 1) }
        else
          nil
        end

      _ -> nil
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

        graphql_struct_attributes = get_graphql_struct_attributes(
          base_ecto_type,
          arg
        )

        if graphql_struct_attributes do
          map = struct(graph_module, graphql_struct_attributes)
          { :ok, map }
        else
          { :error }
        end
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
      |> Enum.filter(fn(m) -> elem(m, 1)[:name] == graphql_type end)

    base_ecto_type = if (length(base_ecto_type) > 1) do
      Enum.find(base_ecto_type, fn(m) -> elem(m, 1)[:closest] == true end)
    else
      Enum.at(base_ecto_type, 0)
    end

    base_ecto_type = elem(base_ecto_type, 0)

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
    def parse_value(_, value), do: Ecto.DateTime.cast!(value)
    def serialize(_, value), do: Ecto.DateTime.to_iso8601(value)
  end

end
