defmodule Vivid.Polygon.Fill do
  alias Vivid.{Line, Point, Polygon}

  @moduledoc ~S"""
  Computes the filled area of a polygon by scanline conversion.

  For each scanline the polygon's edges are intersected with it, the
  intersections sorted by `x`, and the spans between them filled according to
  the non-zero winding rule - the same rule used by PostScript, PDF, SVG and
  Canvas. A span is inside the polygon whenever the number of upward edge
  crossings to its left differs from the number of downward ones, which means
  vertex order determines what counts as inside for self-intersecting polygons.

  Edges are tested against a scanline over the half-open interval
  `y_min <= y < y_max`. This counts a vertex the edges merely pass through once
  and a vertex at a local minimum or maximum not at all, so vertices lying
  exactly on a scanline need no special handling. Horizontal edges fall out of
  the same test and are discarded.

  The returned area includes the pixels the edges themselves pass through, so
  it is the whole filled shape rather than just its interior.

  ## Example

  Filling a notched polygon.

      iex> use Vivid
      ...> frame = Frame.init(16, 16, RGBA.black())
      ...> polygon = Polygon.init([Point.init(1, 1), Point.init(4, 1), Point.init(4, 7), Point.init(11, 7), Point.init(11, 1), Point.init(14, 1), Point.init(14, 14), Point.init(1, 14)])
      ...> Frame.push(frame, Group.init(Vivid.Polygon.Fill.fill(polygon)), RGBA.white())
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
  Returns the points making up the filled area of `polygon` as a `MapSet`.

  ## Examples

  A triangle, whose sloped edges are interpolated per scanline.

      iex> use Vivid
      ...> frame = Frame.init(16, 16, RGBA.black())
      ...> triangle = Polygon.init([Point.init(2, 2), Point.init(13, 2), Point.init(7, 13)])
      ...> Frame.push(frame, Group.init(Vivid.Polygon.Fill.fill(triangle)), RGBA.white())
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
      ...> |> Frame.push(Group.init(Vivid.Polygon.Fill.fill(diamond)), RGBA.white())
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
      ...> |> Frame.push(Group.init(Vivid.Polygon.Fill.fill(pentagram)), RGBA.white())
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
  @spec fill(Polygon.t()) :: MapSet.t()
  def fill(%Polygon{vertices: vertices} = polygon) do
    edges =
      polygon
      |> Polygon.to_lines()
      |> Enum.reject(&horizontal?(&1))

    {y_min, y_max} = vertices |> Enum.map(& &1.y) |> Enum.min_max()

    Enum.reduce(ceil(y_min)..floor(y_max)//1, MapSet.new(), fn y, points ->
      edges
      |> crossings(y)
      |> spans()
      |> Enum.reduce(points, &fill_span(&1, &2, y))
    end)
  end

  defp horizontal?(%Line{origin: %Point{y: y}, termination: %Point{y: y}}), do: true
  defp horizontal?(_line), do: false

  defp crossings(edges, y) do
    edges
    |> Enum.filter(&crosses?(&1, y))
    |> Enum.map(&{crossing_x(&1, y), winding_direction(&1)})
    |> Enum.sort()
  end

  defp crosses?(%Line{origin: %Point{y: y0}, termination: %Point{y: y1}}, y),
    do: min(y0, y1) <= y and y < max(y0, y1)

  defp crossing_x(%Line{origin: p0, termination: p1}, y),
    do: p0.x + (y - p0.y) * (p1.x - p0.x) / (p1.y - p0.y)

  defp winding_direction(%Line{origin: %Point{y: y0}, termination: %Point{y: y1}})
       when y1 > y0,
       do: 1

  defp winding_direction(_line), do: -1

  defp spans(crossings) do
    {_winding, _start, spans} = Enum.reduce(crossings, {0, nil, []}, &accumulate_span(&1, &2))
    Enum.reverse(spans)
  end

  defp accumulate_span({x, direction}, {0, _start, spans}), do: {direction, x, spans}

  defp accumulate_span({x, direction}, {winding, start, spans})
       when winding + direction == 0,
       do: {0, nil, [{start, x} | spans]}

  defp accumulate_span({_x, direction}, {winding, start, spans}),
    do: {winding + direction, start, spans}

  defp fill_span({x_start, x_end}, points, y) do
    Enum.reduce(ceil(x_start)..floor(x_end)//1, points, &MapSet.put(&2, Point.init(&1, y)))
  end
end
