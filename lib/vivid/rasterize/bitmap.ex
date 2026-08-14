defimpl Vivid.Rasterize, for: Vivid.Bitmap do
  alias Vivid.{Bitmap, Bounds, Point}

  @moduledoc """
  Rasterizes a Bitmap.
  """

  @doc ~S"""
  Rasterize all points of `bitmap` within `bounds` into a `MapSet`.

  Each lit cell covers whole frame pixels directly, without being filled or
  outlined like a polygon would be, which is what keeps a cell exactly one pixel
  at one unit per cell instead of spreading into its neighbours.

  ## Example

      iex> Vivid.Bitmap.init([{1, 1}])
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      MapSet.new([Vivid.Point.init(1, 1)])

  At two units per cell the same cell covers four pixels.

      iex> Vivid.Bitmap.init([{1, 1}], Vivid.Point.init(0, 0), 2)
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      MapSet.new([
        Vivid.Point.init(2, 2), Vivid.Point.init(2, 3),
        Vivid.Point.init(3, 2), Vivid.Point.init(3, 3)
      ])
  """
  @impl true
  def rasterize(%Bitmap{pixels: pixels, origin: origin, size: size}, bounds) do
    min = Bounds.min(bounds)
    max = Bounds.max(bounds)
    x_origin = Point.x(origin)
    y_origin = Point.y(origin)

    Enum.reduce(pixels, MapSet.new(), fn {column, row}, points ->
      columns = clamp(Bitmap.cell_span(x_origin, column, size), Point.x(min), Point.x(max))
      rows = clamp(Bitmap.cell_span(y_origin, row, size), Point.y(min), Point.y(max))

      for x <- columns, y <- rows, into: points, do: Point.init(x, y)
    end)
  end

  defp clamp(first..last//_, low, high),
    do: max(first, ceil(low))..min(last, floor(high))//1
end
