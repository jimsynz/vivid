defimpl Vivid.Transformable, for: Vivid.Polygon do
  alias Vivid.{Polygon, Transformable}

  def transform(polygon, fun) do
    polygon
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Polygon.init)
  end
end