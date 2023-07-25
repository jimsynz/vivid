defimpl Vivid.Transformable, for: Vivid.Polygon do
  alias Vivid.{Polygon, Transformable}

  @doc """
  Apply an arbitrary transformation function to a polygon.

  * `polygon` - the polygon to modify.
  * `fun` - the transformation function to apply.
  """
  @impl true
  def transform(%Polygon{fill: fill} = polygon, fun) do
    polygon
    |> Stream.map(&Transformable.transform(&1, fun))
    |> Enum.into(Polygon.init([], fill))
  end
end
