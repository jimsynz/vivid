defimpl Vivid.Bounds.Of, for: Vivid.Polygon do
  alias Vivid.{Polygon, Point}

  @spec bounds(Polygon.t) :: {Point.t, Point.t}
  def bounds(%Polygon{vertices: points}), do: Vivid.Bounds.Of.bounds(points)
end
