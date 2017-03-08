defimpl Vivid.Transformable, for: Vivid.Box do
  alias Vivid.{Box, Transformable, Point}

  @spec transform(Box.t, (Point.t -> Point.t)) :: Box.t
  def transform(box, fun) do
    box
    |> Box.to_polygon
    |> Transformable.transform(fun)
  end
end
