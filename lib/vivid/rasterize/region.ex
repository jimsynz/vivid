defimpl Vivid.Rasterize, for: Vivid.Region do
  alias Vivid.{Coverage, Polygon, Region}
  alias Vivid.Polygon.Fill

  @moduledoc """
  Rasterizes a Region.
  """

  @doc ~S"""
  Rasterize all points of `region` within `bounds`.

  Like a filled `Vivid.Polygon`, the filled area is unioned with the rasterized
  contours themselves, so the edges are included whatever their slope.

  ## Examples

  A four by four square with a hole wound against it. The centre of the hole is
  not part of the rasterized region.

      iex> outside = Vivid.Polygon.init([Vivid.Point.init(0, 0), Vivid.Point.init(4, 0), Vivid.Point.init(4, 4), Vivid.Point.init(0, 4)])
      ...> inside = Vivid.Polygon.init([Vivid.Point.init(1, 1), Vivid.Point.init(1, 3), Vivid.Point.init(3, 3), Vivid.Point.init(3, 1)])
      ...> Vivid.Region.init([outside, inside])
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      ...> |> Vivid.Coverage.covers?(Vivid.Point.init(2, 2))
      false

  The hole's own edges are, though, in the same way a filled polygon includes
  its border.

      iex> outside = Vivid.Polygon.init([Vivid.Point.init(0, 0), Vivid.Point.init(4, 0), Vivid.Point.init(4, 4), Vivid.Point.init(0, 4)])
      ...> inside = Vivid.Polygon.init([Vivid.Point.init(1, 1), Vivid.Point.init(1, 3), Vivid.Point.init(3, 3), Vivid.Point.init(3, 1)])
      ...> Vivid.Region.init([outside, inside])
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      ...> |> Vivid.Coverage.covers?(Vivid.Point.init(2, 1))
      true
  """
  @impl true
  def rasterize(%Region{contours: contours}, bounds) do
    contours
    |> Fill.fill(bounds)
    |> Coverage.union(contour_borders(contours, bounds))
  end

  defp contour_borders(contours, bounds) do
    Coverage.from_lines(bounds, Enum.flat_map(contours, &Polygon.to_lines(&1)))
  end
end
