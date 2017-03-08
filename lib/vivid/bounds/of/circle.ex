defimpl Vivid.Bounds.Of, for: Vivid.Circle do
  alias Vivid.{Circle, Bounds, Point}

  @spec bounds(Circle.t) :: {Point.t, Point.t}
  def bounds(circle) do
    circle
    |> Circle.to_polygon
    |> Bounds.Of.bounds
  end
end
