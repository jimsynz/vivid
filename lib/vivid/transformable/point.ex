defimpl Vivid.Transformable, for: Vivid.Point do
  alias Vivid.Point

  @spec transform(Point.t, (Point.t -> Point.t)) :: Point.t
  def transform(point, fun), do: fun.(point)
end
