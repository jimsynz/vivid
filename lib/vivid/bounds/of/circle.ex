defimpl Vivid.Bounds.Of, for: Vivid.Circle do
  alias Vivid.{Circle, Bounds, Point}

  @doc """
  Find the bounds of a `circle`.

  Returns a two-element tuple of the bottom-left and top-right points.
  """
  @spec bounds(Circle.t) :: {Point.t, Point.t}
  def bounds(circle) do
    circle
    |> Circle.to_polygon
    |> Bounds.Of.bounds
  end
end
