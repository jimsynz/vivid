defimpl Vivid.Bounds.Of, for: Vivid.Bitmap do
  alias Vivid.{Bitmap, Point}

  @doc """
  Find the bounds of a `bitmap`.

  Returns a two-element tuple of the bottom-left and top-right points, or `nil`
  if nothing in it is lit.

  The bounds are the pixels the bitmap actually covers rather than the corners of
  its cells, so a single lit cell one unit wide is one pixel rather than a square
  with a pixel at each corner.
  """
  @impl true
  def bounds(%Bitmap{pixels: []} = _bitmap), do: nil

  def bounds(%Bitmap{pixels: pixels, origin: origin, size: size} = _bitmap) do
    {columns, rows} = Enum.unzip(pixels)
    {first_column, last_column} = Enum.min_max(columns)
    {first_row, last_row} = Enum.min_max(rows)

    {Point.init(
       Bitmap.cell_span(Point.x(origin), first_column, size).first,
       Bitmap.cell_span(Point.y(origin), first_row, size).first
     ),
     Point.init(
       Bitmap.cell_span(Point.x(origin), last_column, size).last,
       Bitmap.cell_span(Point.y(origin), last_row, size).last
     )}
  end
end
