defimpl Vivid.Bounds.Of, for: Vivid.Path do
  alias Vivid.{Path, Point}

  @spec bounds(Path.t) :: {Point.t, Point.t}
  def bounds(%Path{vertices: points}), do: Vivid.Bounds.Of.bounds(points)
end
