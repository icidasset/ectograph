defmodule Ectograph.Type do

  @map %{
    :array      => "List",
    :boolean    => "Boolean",
    :datetime   => "DateTime",
    :float      => "Float",
    :id         => "ID",
    :integer    => "Int",
    :map        => "Map",

    :string     => "String",
    :uuid       => "String",
    :binary_id  => "String",
  }


  @map_custom [
    "DateTime",
    "Map"
  ]


  @docp """
    Given a basic ecto type (see keys from the @map above)
    and the original ecto type, return the appropriate set of attributes.

    e.g. given `:array` and `{ :array, :string }`, return `{ ofType: :string }`.
  """
  defp get_graphql_struct_attributes(base_ecto_type, arg) do
    case base_ecto_type do
      :array ->
        { state, type } = cast elem(arg, 1)

        case state do
          :ok -> %{ ofType: type }
          :error -> nil
        end

      _ ->
        %{}
    end
  end


  @docp """
    Given an ecto type, return the basic ecto type.
    See keys from @map.
  """
  defp get_base_ecto_type(arg) do
    ecto_type = Ecto.Type.type(arg)

    cond do
      is_tuple(ecto_type) -> elem(ecto_type, 0)
      true -> ecto_type
    end
  end


  @doc """
    Cast a Ecto type (atom | tuple | module) to a GraphQL type (struct).

    @return { :ok | :error, value }
  """
  def cast(arg) do
    base_ecto_type  = get_base_ecto_type(arg)
    graphql_type    = @map[base_ecto_type]
    is_custom       = Enum.member?(@map_custom, graphql_type)
    mod_base        = if is_custom, do: Ectograph.Type.Custom, else: GraphQL.Type

    case graphql_type do
      nil ->
        { :error }

      _ ->
        mod_graph             = Module.concat([mod_base, graphql_type])
        graphql_struct_attr   = get_graphql_struct_attributes(base_ecto_type, arg)

        if graphql_struct_attr,
          do: { :ok, struct(mod_graph, graphql_struct_attr) },
        else: { :error }
    end
  end



  # {custom-type} DateTime
  #
  defmodule Custom.DateTime do
    defstruct name: "DateTime", description:
      """
      The `DateTime` type represents a datetime value in the ISO8601 format.
      """
  end

  defimpl GraphQL.Types, for: Custom.DateTime do
    def parse_value(_, value), do: Ecto.DateTime.cast!(value)
    def serialize(_, value), do: Ecto.DateTime.to_iso8601(value)
    def parse_literal(_, value), do: value
  end



  # {custom-type} Map
  #
  defmodule Custom.Map do
    defstruct name: "Map", description:
      """
      A custom type that translates ...

      ```
      createMutation (
        argument: { example: "test" }
      ) {}
      ```

      into an elixir map.
      """

    def parse(value) do
      if is_map(value) && Map.has_key?(value, :fields) do
        Enum.reduce value.fields, %{}, fn(f, acc) ->
          Map.put(acc, f.name.value, f.value.value)
        end
      else
        value
      end
    end

  end

  defimpl GraphQL.Types, for: Custom.Map do
    def parse_value(_, value), do: Custom.Map.parse(value)
    def serialize(_, value), do: value
    def parse_literal(_, value), do: Custom.Map.parse(value)
  end

end
