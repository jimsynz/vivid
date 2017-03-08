defimpl Vivid.Bounds.Of, for: Vivid.Point do
  alias Vivid.Point

  @spec bounds(Point.t) :: {Point.t, Point.t}
  def bounds(point), do: {point, point}
end
