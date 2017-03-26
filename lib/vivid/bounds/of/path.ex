defimpl Vivid.Bounds.Of, for: Vivid.Path do
  alias Vivid.{Path, Point}

  @doc """
  Find the bounds of a `path`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @spec bounds(Path.t) :: {Point.t, Point.t}
  def bounds(%Path{vertices: points} = _path), do: Vivid.Bounds.Of.bounds(points)
end
