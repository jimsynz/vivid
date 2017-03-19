defimpl Vivid.Transformable, for: Vivid.Polygon do
  alias Vivid.{Polygon, Transformable}

  @spec transform(Polygon.t, (Point.t -> Point.t)) :: Polygon.t
  def transform(%Polygon{fill: fill} = polygon, fun) do
    polygon
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Polygon.init([], fill))
  end
end
