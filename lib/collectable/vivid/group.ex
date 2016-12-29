defimpl Collectable, for: Vivid.Group do
  alias Vivid.Group

  @doc """
  Collect an enumerable into a Group.

  ## Examples

      iex> [Vivid.Point.init(1,1)] |> Enum.into(Vivid.Group.init)
      %Vivid.Group{shapes: MapSet.new([%Vivid.Point{x: 1, y: 1}])}
  """

  def into(%Group{shapes: shapes}) do
    {shapes, fn
      new_shapes, {:cont, shape} -> MapSet.put(new_shapes, shape)
      new_shapes, :done          -> Group.init(MapSet.union(shapes, new_shapes))
      _,          :halt          -> :ok
    end}
  end
end