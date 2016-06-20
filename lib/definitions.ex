defmodule Ectograph.Definitions do

  @doc """
    Build a field (a.k.a. definition).
  """
  def build(resolver, method, attributes \\ nil)


  def build(resolver, :all, attributes) do
    type_def = build_type get_ecto_schema(resolver)

    %{
      type: %GraphQL.Type.List{ ofType: type_def },
      args: pick_types(type_def, attributes),
      resolve: { resolver, :all },
    }
  end


  def build(resolver, method, attributes) do
    type_def = build_type get_ecto_schema(resolver)

    %{
      type: type_def,
      args: pick_types(type_def, attributes),
      resolve: { resolver, method }
    }
  end


  @doc """
    Extend the arguments of a field.

    Given a field (a.k.a. definition)
    of the form `%{ type: %{ fields: %{} }, args: %{} }`,
    it will merge the `args` map with
    the map given as the second argument to this function.
  """
  def extend_arguments(definition, with_map) do
    Map.put(definition, :args, Map.merge(definition.args, with_map))
  end


  @doc """
    Extend the fields of the type of a field.

    Given a field (a.k.a. definition) or a `GraphQL.Type.List`,
    it will merge the `type.fields` map with
    the map given as the second argument to this function.
  """
  def extend_type_fields(definition, with_map) do
    d = definition
    t = definition.type

    f = cond do
      Map.has_key?(t, :fields) -> t.fields
      Map.has_key?(t, :ofType) -> t.ofType.fields
    end

    cond do
      Map.has_key?(t, :fields) -> put_in(d.type.fields, Map.merge(f, with_map))
      Map.has_key?(t, :ofType) -> put_in(d.type.ofType.fields, Map.merge(f, with_map))
      true -> d
    end
  end


  @doc """
    Add an association to a definition.

    e.g.

    ```elixir
    type_def = build(Quote, :all)
    type_def = add_association(type_def, Author, :author) # default is ':single'
    type_def = add_association(type_def, Author, :authors, :multiple)
    ```
  """
  def add_association(definition, resolver, association_name, opt \\ :single) do
    type_def = build_type get_ecto_schema(resolver)
    type_def = case opt do
      :multiple -> %GraphQL.Type.List{ ofType: type_def }
      :single -> type_def
    end

    extend_type_fields(
      definition,
      Map.put_new(%{}, association_name, %{ type: type_def })
    )
  end


  @doc """
    Pick specific fields from a type definition.
    When the second argument is nil, it returns an empty map.

    ```
    pick_types(
      %{ name: "Whatever", fields: %{ a: %{ type: ... }, b: %{ type: ... } }},
      [:a]
    )
    -> %{ a: %{ type: ... } }
    ```
  """
  def pick_types(_, nil) do
    %{}
  end


  def pick_types(type_def, keys) do
    m = type_def
      |> Map.fetch!(:fields)
      |> Map.take(keys)
      |> Map.new()

    m
  end


  #
  # Private
  #

  defp get_ecto_schema(resolver) do
    if Keyword.has_key?(resolver.__info__(:functions), :ecto_schema),
      do: resolver.ecto_schema,
    else: resolver
  end


  defp build_type(ecto_schema) do
    { state, result } = Ectograph.Schema.cast(ecto_schema)

    case state do
      :ok -> result
      :error -> raise "Could not cast Ecto schema `" <> ecto_schema.__schema__(:source) <> "`"
    end
  end

end
