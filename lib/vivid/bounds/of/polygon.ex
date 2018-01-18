defimpl Vivid.Bounds.Of, for: Vivid.Polygon do
  alias Vivid.{Polygon, Point}

  @doc """
  Find the bounds of a `polygon`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @spec bounds(Polygon.t()) :: {Point.t(), Point.t()}
  def bounds(%Polygon{vertices: points} = _polygon), do: Vivid.Bounds.Of.bounds(points)
end
