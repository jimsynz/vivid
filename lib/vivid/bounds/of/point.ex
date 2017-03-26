defimpl Vivid.Bounds.Of, for: Vivid.Point do
  alias Vivid.Point

  @doc """
  Find the bounds of a `point`.

  Since the bounds of a point are simply the point, it returns the point
  twice.
  """
  @spec bounds(Point.t) :: {Point.t, Point.t}
  def bounds(point), do: {point, point}
end
