defmodule Vivid.Polygon.Fill do
  alias Vivid.{Bounds, Coverage, Line, Point, Polygon}

  @moduledoc ~S"""
  Computes the filled area of a polygon by scanline conversion.

  A pixel is inside the polygon when the number of upward edge crossings to its
  left on its own scanline differs from the number of downward ones - the
  non-zero winding rule, the same rule used by PostScript, PDF, SVG and Canvas.
  Vertex order therefore determines what counts as inside for self-intersecting
  polygons.

  Every edge is intersected with every scanline at once, and each crossing is
  added into the column where it starts to count. Summing those along each row
  gives every pixel's winding number in one pass, which is why the crossings
  never need sorting: a prefix sum accumulates them in the order they occur
  along the row for free.

  Because a span includes the pixels at both of its ends, and a running total
  can only change on one side of a crossing, the sum is taken twice - once for
  the columns strictly right of each crossing and once including the crossing's
  own column - and a pixel is inside if either says so.

  Edges are tested against a scanline over the half-open interval
  `y_min <= y < y_max`. This counts a vertex the edges merely pass through once
  and a vertex at a local minimum or maximum not at all, so vertices lying
  exactly on a scanline need no special handling. Horizontal edges fall out of
  the same test and are discarded.

  The returned area includes the pixels the edges themselves pass through, so
  it is the whole filled shape rather than just its interior.

  A list of polygons may be filled as a single area, in which case every
  contour's edges cross the same scanline and contribute to the same winding
  count. A contour wound against the one enclosing it therefore cuts a hole,
  which is what `Vivid.Region` is built on.

  ## Example

  Filling a notched polygon.

      iex> use Vivid
      ...> frame = Frame.init(16, 16, RGBA.black())
      ...> polygon = Polygon.init([Point.init(1, 1), Point.init(4, 1), Point.init(4, 7), Point.init(11, 7), Point.init(11, 1), Point.init(14, 1), Point.init(14, 14), Point.init(1, 14)])
      ...> Frame.push(frame, Group.init(Coverage.to_points(Vivid.Polygon.Fill.fill(polygon))), RGBA.white())
      ...> |> to_string()
      "                \n" <>
      "                \n" <>
      " @@@@@@@@@@@@@@ \n" <>
      " @@@@@@@@@@@@@@ \n" <>
      " @@@@@@@@@@@@@@ \n" <>
      " @@@@@@@@@@@@@@ \n" <>
      " @@@@@@@@@@@@@@ \n" <>
      " @@@@@@@@@@@@@@ \n" <>
      " @@@@@@@@@@@@@@ \n" <>
      " @@@@      @@@@ \n" <>
      " @@@@      @@@@ \n" <>
      " @@@@      @@@@ \n" <>
      " @@@@      @@@@ \n" <>
      " @@@@      @@@@ \n" <>
      " @@@@      @@@@ \n" <>
      "                \n"
  """

  @doc ~S"""
  Returns the coverage of the filled area of `polygon` by its own bounds.

  ## Examples

  A triangle, whose sloped edges are interpolated per scanline.

      iex> use Vivid
      ...> frame = Frame.init(16, 16, RGBA.black())
      ...> triangle = Polygon.init([Point.init(2, 2), Point.init(13, 2), Point.init(7, 13)])
      ...> Frame.push(frame, Group.init(Coverage.to_points(Vivid.Polygon.Fill.fill(triangle))), RGBA.white())
      ...> |> to_string()
      "                \n" <>
      "                \n" <>
      "                \n" <>
      "       @        \n" <>
      "       @@       \n" <>
      "      @@@       \n" <>
      "      @@@@      \n" <>
      "     @@@@@      \n" <>
      "     @@@@@@     \n" <>
      "    @@@@@@@     \n" <>
      "    @@@@@@@@    \n" <>
      "   @@@@@@@@@    \n" <>
      "   @@@@@@@@@@   \n" <>
      "  @@@@@@@@@@@@  \n" <>
      "                \n" <>
      "                \n"

  A diamond, drawn over its own outline. The fill meets the border on every
  edge regardless of the direction of its slope.

      iex> use Vivid
      ...> frame = Frame.init(16, 16, RGBA.black())
      ...> diamond = Polygon.init([Point.init(8, 2), Point.init(14, 8), Point.init(8, 14), Point.init(2, 8)])
      ...> frame
      ...> |> Frame.push(diamond, RGBA.white())
      ...> |> Frame.push(Group.init(Coverage.to_points(Vivid.Polygon.Fill.fill(diamond))), RGBA.white())
      ...> |> to_string()
      "                \n" <>
      "        @       \n" <>
      "       @@@      \n" <>
      "      @@@@@     \n" <>
      "     @@@@@@@    \n" <>
      "    @@@@@@@@@   \n" <>
      "   @@@@@@@@@@@  \n" <>
      "  @@@@@@@@@@@@@ \n" <>
      "   @@@@@@@@@@@  \n" <>
      "    @@@@@@@@@   \n" <>
      "     @@@@@@@    \n" <>
      "      @@@@@     \n" <>
      "       @@@      \n" <>
      "        @       \n" <>
      "                \n" <>
      "                \n"

  A self-intersecting pentagram with fractional vertices. Under the non-zero
  winding rule the centre is inside the polygon, so it fills solid; the
  even-odd rule would leave it hollow.

      iex> use Vivid
      ...> frame = Frame.init(21, 21, RGBA.black())
      ...> pentagram = Polygon.init([Point.init(10, 18.5), Point.init(5.004, 3.123), Point.init(18.084, 12.627), Point.init(1.916, 12.627), Point.init(14.996, 3.123)])
      ...> frame
      ...> |> Frame.push(pentagram, RGBA.white())
      ...> |> Frame.push(Group.init(Coverage.to_points(Vivid.Polygon.Fill.fill(pentagram))), RGBA.white())
      ...> |> to_string()
      "                     \n" <>
      "          @          \n" <>
      "          @          \n" <>
      "         @@@         \n" <>
      "         @@@         \n" <>
      "         @@@         \n" <>
      "        @@@@@        \n" <>
      "  @@@@@@@@@@@@@@@@@  \n" <>
      "   @@@@@@@@@@@@@@@   \n" <>
      "    @@@@@@@@@@@@@    \n" <>
      "      @@@@@@@@@      \n" <>
      "       @@@@@@@       \n" <>
      "       @@@@@@@       \n" <>
      "      @@@@@@@@@      \n" <>
      "      @@@@ @@@@      \n" <>
      "      @@@   @@@      \n" <>
      "     @@       @@     \n" <>
      "     @         @     \n" <>
      "                     \n" <>
      "                     \n" <>
      "                     \n"
  """
  @spec fill(Polygon.t() | [Polygon.t()]) :: Coverage.t()
  def fill([]), do: Coverage.none()
  def fill(contours) when is_list(contours), do: fill(contours, Bounds.bounds(contours))
  def fill(%Polygon{} = polygon), do: fill([polygon], Bounds.bounds(polygon))

  @doc ~S"""
  Returns the coverage of `bounds` by the filled area of `polygon`.

  The grid is the size of `bounds` and nothing else, so filling a polygon much
  larger than the area you care about costs no more than the area itself.

  ## Example

  A polygon overhanging the frame on every side, clipped to the middle of it.

      iex> use Vivid
      ...> frame = Frame.init(8, 8, RGBA.black())
      ...> polygon = Polygon.init([Point.init(-5, -5), Point.init(12, -5), Point.init(12, 12), Point.init(-5, 12)])
      ...> Frame.push(frame, Group.init(Coverage.to_points(Vivid.Polygon.Fill.fill(polygon, Bounds.init(2, 2, 5, 5)))), RGBA.white())
      ...> |> to_string()
      "        \n" <>
      "        \n" <>
      "  @@@@  \n" <>
      "  @@@@  \n" <>
      "  @@@@  \n" <>
      "  @@@@  \n" <>
      "        \n" <>
      "        \n"
  """
  @spec fill(Polygon.t() | [Polygon.t()], Bounds.t()) :: Coverage.t()
  def fill([], bounds), do: Coverage.empty(bounds)
  def fill(%Polygon{} = polygon, bounds), do: fill([polygon], bounds)

  def fill(contours, bounds) when is_list(contours) do
    case contours |> Enum.flat_map(&Polygon.to_lines(&1)) |> Enum.reject(&horizontal?(&1)) do
      [] -> Coverage.empty(bounds)
      edges -> Coverage.from_tensor(bounds, clipped(edges, bounds))
    end
  end

  # Only the part of the bounds the contours actually reach can be filled, so
  # that is the only part worth computing a winding number for; the rest is
  # padded back on. Without this a glyph on a large frame costs the whole frame,
  # which is what the scanline range of the scalar version was avoiding.
  defp clipped(edges, bounds) do
    %Point{x: x_first, y: y_first} = Bounds.min(bounds)
    %Point{x: x_last, y: y_last} = Bounds.max(bounds)
    {x_low, x_high, y_low, y_high} = extent(edges)

    x_from = max(ceil(x_first), floor(x_low))
    x_to = min(floor(x_last), ceil(x_high))
    y_from = max(ceil(y_first), floor(y_low))
    y_to = min(floor(y_last), ceil(y_high))

    if x_to < x_from or y_to < y_from do
      Nx.broadcast(
        0,
        {max(floor(y_last) - ceil(y_first) + 1, 0), max(floor(x_last) - ceil(x_first) + 1, 0)}
      )
    else
      edges
      |> inside(Bounds.init(x_from, y_from, x_to, y_to))
      |> Nx.pad(0, [
        {y_from - ceil(y_first), floor(y_last) - y_to, 0},
        {x_from - ceil(x_first), floor(x_last) - x_to, 0}
      ])
    end
  end

  defp extent(edges) do
    xs =
      Enum.flat_map(edges, fn %Line{origin: %Point{x: a}, termination: %Point{x: b}} -> [a, b] end)

    ys =
      Enum.flat_map(edges, fn %Line{origin: %Point{y: a}, termination: %Point{y: b}} -> [a, b] end)

    {x_low, x_high} = Enum.min_max(xs)
    {y_low, y_high} = Enum.min_max(ys)

    {x_low, x_high, y_low, y_high}
  end

  defp horizontal?(%Line{origin: %Point{y: y}, termination: %Point{y: y}}), do: true
  defp horizontal?(_line), do: false

  # A pixel is filled when its winding number is non-zero, and its winding
  # number is the sum of the directions of the edges crossing its scanline to
  # its left. Summing that from the left is a cumulative sum along the row, so
  # the crossings never need sorting: each one is added into the column where it
  # starts having an effect, and every column downstream of it inherits the
  # total.
  #
  # Which columns a crossing affects depends on whether the comparison against
  # it is strict, and a span is closed at both ends, so it's counted twice - the
  # first pass gives the columns of `x <= c` and the second those of `x < c`,
  # and a pixel is inside if either says so.
  defp inside(edges, bounds) do
    %Point{x: x_first, y: y_first} = Bounds.min(bounds)
    %Point{x: x_last, y: y_last} = Bounds.max(bounds)
    columns = max(floor(x_last) - ceil(x_first) + 1, 0)
    rows = max(floor(y_last) - ceil(y_first) + 1, 0)

    scanlines = Nx.iota({1, rows}) |> Nx.add(ceil(y_first)) |> Nx.as_type({:f, 64})
    {x0, y0, x1, y1} = coordinates(edges)

    crossing =
      Nx.less_equal(Nx.min(y0, y1), scanlines)
      |> Nx.logical_and(Nx.less(scanlines, Nx.max(y0, y1)))

    crossing_x =
      scanlines
      |> Nx.subtract(y0)
      |> Nx.multiply(Nx.divide(Nx.subtract(x1, x0), Nx.subtract(y1, y0)))
      |> Nx.add(x0)

    direction = Nx.select(Nx.greater(y1, y0), 1, -1) |> Nx.multiply(crossing)

    [Nx.ceil(crossing_x), Nx.add(Nx.floor(crossing_x), 1)]
    |> Enum.map(&winding(&1, direction, crossing, ceil(x_first), rows, columns))
    |> Enum.reduce(&Nx.logical_or/2)
  end

  defp coordinates(edges) do
    edges
    |> Enum.map(fn %Line{origin: %Point{x: x0, y: y0}, termination: %Point{x: x1, y: y1}} ->
      [x0, y0, x1, y1]
    end)
    |> Nx.tensor(type: {:f, 64})
    |> Nx.transpose()
    |> Nx.new_axis(-1)
    |> then(fn tensor -> {tensor[0], tensor[1], tensor[2], tensor[3]} end)
  end

  defp winding(_from, _direction, _crossing, _x_first, rows, columns)
       when rows == 0 or columns == 0,
       do: Nx.broadcast(0, {rows, columns})

  defp winding(from, direction, crossing, x_first, rows, columns) do
    pixels = rows * columns
    column = from |> Nx.subtract(x_first) |> Nx.as_type({:s, 64}) |> Nx.max(0)

    row = Nx.iota({1, rows}) |> Nx.broadcast(Nx.shape(column))

    indices =
      crossing
      |> Nx.logical_and(Nx.less(column, columns))
      |> Nx.select(Nx.add(Nx.multiply(row, columns), column), pixels)
      |> Nx.reshape({:auto, 1})

    Nx.broadcast(0, {pixels + 1})
    |> Nx.indexed_add(indices, Nx.reshape(direction, {:auto}))
    |> Nx.slice([0], [pixels])
    |> Nx.reshape({rows, columns})
    |> Nx.cumulative_sum(axis: 1)
    |> Nx.not_equal(0)
  end
end
