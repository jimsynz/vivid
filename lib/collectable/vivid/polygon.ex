defimpl Collectable, for: Vivid.Polygon do
  alias Vivid.{Polygon, Point}

  @doc """
  Collect an enumerable into a Polygon.

  ## Examples

      iex> [Vivid.Point.init(1,1)] |> Enum.into(Vivid.Polygon.init)
      %Vivid.Polygon{vertices: [%Vivid.Point{x: 1, y: 1}]}
  """

  def into(%Polygon{vertices: points}) do
    {[], fn
      list, {:cont, %Point{}=point} -> [ point | list ]
      list, :done                   -> Polygon.init(points ++ list)
      _,    :halt                   -> :ok
    end}
  end
end