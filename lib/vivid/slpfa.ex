defmodule Vivid.SLPFA do
  alias Vivid.{Line, Point, Polygon}

  @moduledoc """
  Scanline Polygon Filling Algorithm, as per
  https://hackernoon.com/computer-graphics-scan-line-polygon-fill-algorithm-3cb47283df6#.20fac9f40

  This algorithm only fills the *inside* of a polygon, leaving you free to
  to compose it with the original polygon if you want to use different border
  and fill colours, for example.
  """

  defmodule EdgeBucket do
    defstruct ~w(y_min y_max x sign distance_x distance_y sum)a
    @moduledoc false

    @type t :: %EdgeBucket{
            y_min: non_neg_integer(),
            y_max: non_neg_integer(),
            sign: -1 | 1,
            distance_x: non_neg_integer(),
            distance_y: non_neg_integer(),
            sum: non_neg_integer()
          }
  end

  @doc ~S"""
  Fills the inside area of a polygon using the Scanline Polygon Filling
  Algorithm.

  ## Examples

  The original polygon.

      iex> use Vivid
      ...> frame = Frame.init(16, 16, RGBA.black)
      ...> polygon = Polygon.init([Point.init(1, 1), Point.init(4, 1), Point.init(4, 7), Point.init(11, 7), Point.init(11, 1), Point.init(14, 1), Point.init(14, 14), Point.init(1, 14)])
      ...> Frame.push(frame, polygon, RGBA.white)
      ...>   |> to_string
      "                \n" <>
      " @@@@@@@@@@@@@@ \n" <>
      " @            @ \n" <>
      " @            @ \n" <>
      " @            @ \n" <>
      " @            @ \n" <>
      " @            @ \n" <>
      " @            @ \n" <>
      " @  @@@@@@@@  @ \n" <>
      " @  @      @  @ \n" <>
      " @  @      @  @ \n" <>
      " @  @      @  @ \n" <>
      " @  @      @  @ \n" <>
      " @  @      @  @ \n" <>
      " @@@@      @@@@ \n" <>
      "                \n"

  The filled area of the polygon

      iex> use Vivid
      ...> frame = Frame.init(16, 16, RGBA.black)
      ...> polygon = Polygon.init([Point.init(1, 1), Point.init(4, 1), Point.init(4, 7), Point.init(11, 7), Point.init(11, 1), Point.init(14, 1), Point.init(14, 14), Point.init(1, 14)]) |> Vivid.SLPFA.fill |> Group.init
      ...> Frame.push(frame, polygon, RGBA.white)
      ...>   |> to_string
      "                \n" <>
      "                \n" <>
      "  @@@@@@@@@@@@  \n" <>
      "  @@@@@@@@@@@@  \n" <>
      "  @@@@@@@@@@@@  \n" <>
      "  @@@@@@@@@@@@  \n" <>
      "  @@@@@@@@@@@@  \n" <>
      "  @@@@@@@@@@@@  \n" <>
      "  @@@@@@@@@@@@  \n" <>
      "  @@        @@  \n" <>
      "  @@        @@  \n" <>
      "  @@        @@  \n" <>
      "  @@        @@  \n" <>
      "  @@        @@  \n" <>
      "  @@        @@  \n" <>
      "                \n"

  The polygon and the fill combined.

      iex> use Vivid
      ...> frame = Frame.init(16, 16, RGBA.black)
      ...> polygon = Polygon.init([Point.init(1, 1), Point.init(4, 1), Point.init(4, 7), Point.init(11, 7), Point.init(11, 1), Point.init(14, 1), Point.init(14, 14), Point.init(1, 14)])
      ...> inside = polygon |> Vivid.SLPFA.fill |> Group.init
      ...> Frame.push(frame, polygon, RGBA.white)
      ...>   |> Frame.push(inside, RGBA.white)
      ...>   |> to_string
      "                \n" <>
      " @@@@@@@@@@@@@@ \n" <>
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
  @spec fill(Polygon.t()) :: MapSet.t()
  def fill(%Polygon{vertices: vertices}) do
    vertices
    |> create_edge_table
    |> process_edge_table
  end

  defp process_edge_table([a0 | _] = edge_table) do
    scan_line = a0.y_min
    {active, edge_table} = update_active_list(scan_line, [], edge_table)
    points = pixels_for_active_list(MapSet.new(), active, scan_line)
    process_edge_table(points, active, edge_table, scan_line + 1)
  end

  defp process_edge_table(points, [] = _active, _edge_table, _scan_line), do: points

  defp process_edge_table(points, active, edge_table, scan_line) do
    {active, edge_table} = update_active_list(scan_line, active, edge_table)
    points = pixels_for_active_list(points, active, scan_line)
    new_active = increment_active_edges(active)
    process_edge_table(points, new_active, edge_table, scan_line + 1)
  end

  defp increment_active_edges(active) do
    Enum.map(active, fn
      %EdgeBucket{distance_x: 0} = edge_bucket ->
        edge_bucket

      %EdgeBucket{distance_x: dx, sum: s} = edge_bucket ->
        edge_bucket
        |> Map.put(:sum, s + dx)
        |> increment_edge
    end)
  end

  defp increment_edge(%EdgeBucket{sum: sum, distance_y: dy, sign: sign, x: x} = edge_bucket)
       when sum >= dy do
    edge_bucket
    |> Map.put(:x, x + sign)
    |> Map.put(:sum, sum - dy)
    |> increment_edge
  end

  defp increment_edge(edge_bucket), do: edge_bucket

  defp pixels_for_active_list(points, active, y) do
    active
    |> Stream.chunk_every(2)
    |> Enum.reduce(points, fn [a0, a1], points ->
      Enum.reduce((a0.x + 1)..(a1.x - 1), points, fn x, points ->
        MapSet.put(points, Point.init(x, y))
      end)
    end)
  end

  defp update_active_list(scan_line, active, edge_table) do
    {active, edge_table} =
      active
      |> Stream.concat(edge_table)
      |> Enum.reduce({[], []}, fn
        %EdgeBucket{y_min: y_min, y_max: y_max} = edge, {active, edge_table}
        when y_min <= scan_line and y_max > scan_line ->
          active = [edge | active]
          {active, edge_table}

        %EdgeBucket{y_min: y_min} = edge, {active, edge_table} when y_min >= scan_line ->
          edge_table = [edge | edge_table]
          {active, edge_table}

        _edge_bucket, {active, edge_table} ->
          {active, edge_table}
      end)

    new_active =
      active
      |> Enum.sort(&sort_by_x_and_slope(&1, &2))

    {new_active, edge_table}
  end

  defp sort_by_x_and_slope(%EdgeBucket{x: x0}, %EdgeBucket{x: x1})
       when x0 < x1,
       do: true

  defp sort_by_x_and_slope(%EdgeBucket{x: x0}, %EdgeBucket{x: x1})
       when x0 > x1,
       do: false

  defp sort_by_x_and_slope(%EdgeBucket{distance_x: dx0, distance_y: dy0}, %EdgeBucket{
         distance_x: dx1,
         distance_y: dy1
       }),
       do: dx0 / dy0 < dx1 / dy1

  defp create_edge_table(vertices) do
    vertices
    |> Stream.with_index()
    |> Stream.map(fn {p0, idx} ->
      p1 = Enum.at(vertices, idx - 1)
      Line.init(p0, p1)
    end)
    |> Stream.map(&line_left_to_right(&1))
    |> Stream.map(&line_to_edge_bucket(&1))
    |> Stream.reject(&horizontal_line?(&1))
    |> Enum.sort(&sort_by_min_y(&1, &2))
  end

  defp line_left_to_right(%Line{origin: %Point{x: x0} = p0, termination: %Point{x: x1} = p1})
       when x0 > x1,
       do: Line.init(p1, p0)

  defp line_left_to_right(line), do: line

  defp line_to_edge_bucket(%Line{origin: p0, termination: p1}) do
    y_max = if p0.y > p1.y, do: p0.y, else: p1.y
    y_min = if p0.y < p1.y, do: p0.y, else: p1.y
    init_x = if p0.y < p1.y, do: p0.x, else: p1.x
    sign = if p1.y - p0.y < 0, do: -1, else: 1
    dx = abs(p1.x - p0.x)
    dy = abs(p1.y - p0.y)

    %EdgeBucket{
      y_min: round(y_min),
      y_max: round(y_max),
      x: round(init_x),
      sign: sign,
      distance_x: round(dx),
      distance_y: round(dy),
      sum: 0
    }
  end

  defp horizontal_line?(%EdgeBucket{distance_y: 0}), do: true
  defp horizontal_line?(_edge_bucket), do: false

  defp sort_by_min_y(%EdgeBucket{y_min: y_min0}, %EdgeBucket{y_min: y_min1}), do: y_min1 > y_min0
end
