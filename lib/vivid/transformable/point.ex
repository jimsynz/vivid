defimpl Vivid.Transformable, for: Vivid.Point do
  alias Vivid.Point

  @doc """
  Apply an arbitrary transformation function to a point.

  * `point` - the point to modify.
  * `fun` - the transformation function to apply.
  """
  @spec transform(Point.t(), (Point.t() -> Point.t())) :: Point.t()
  def transform(point, fun), do: fun.(point)
end
