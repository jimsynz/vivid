defimpl Vivid.Transformable, for: Vivid.Circle do
  alias Vivid.{Circle, Transformable, Polygon}

  @doc """
  Apply an arbitrary transformation function to a circle.

  * `circle` - the circle to modify.
  * `fun` - the transformation function to apply.

  Many of the transformations can't be applied to a Circle, but we
  can convert it to a polygon and then use that to apply transformations.
  """
  @spec transform(Circle.t, (Point.t -> Point.t)) :: Polygon.t
  def transform(%Circle{fill: f} = circle, fun) do
    circle
    |> Circle.to_polygon
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Polygon.init([], f))
  end
end
