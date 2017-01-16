defmodule Vivid.SLPFA do
  alias Vivid.{Polygon, Point, Line}

  @moduledoc """
  Scanline Polygon Filling Algorithm, as per
  https://hackernoon.com/computer-graphics-scan-line-polygon-fill-algorithm-3cb47283df6#.20fac9f40
  """

  defmodule EdgeBucket do
    defstruct ~w(y_min y_max x sign distance_x distance_y sum)a
    @moduledoc false
  end

  def fill(%Polygon{vertices: vertices}=polygon) do
    vertices
    |> create_edge_table
    |> process_edge_table
  end

  defp process_edge_table([active0, active1 | edge_table]) do
    scan_line = active0.y_min
    active = [active0, active1]
    points = pixels_for_active_list(MapSet.new, active, scan_line)
    process_edge_table(points, active, edge_table, scan_line + 1)
  end

  defp process_edge_table(points, _active, [], scan_line), do: points

  defp process_edge_table(points, active, edge_table, scan_line) do
    active = update_active_list(scan_line, active, edge_table)
    points = pixels_for_active_list(points, active, scan_line)
    active = increment_active_edges(active)
    process_edge_table(points, active, edge_table, scan_line + 1)
  end

  defp increment_active_edges(active) do
    Enum.map(active, fn
      %EdgeBucket{distance_x: 0}=edge_bucket ->
        edge_bucket
      %EdgeBucket{distance_x: dx, sum: s}=edge_bucket ->
        edge_bucket = edge_bucket
          |> Map.put(:sum, s + dx)
          |> increment_edge
    end)
  end

  defp increment_edge(%EdgeBucket{sum: sum, distance_y: dy, sign: sign, x: x}=edge_bucket) when sum >= dy do
    edge_bucket
    |> Map.put(:x, x + sign)
    |> Map.put(:sum, sum - dy)
    |> increment_edge
  end

  defp increment_edge(edge_bucket), do: edge_bucket

  defp pixels_for_active_list(points, active, y) do
    active
    |> Stream.chunk(2)
    |> Enum.reduce(points, fn [a0, a1], points ->
      Enum.reduce(a0.x..a1.x, points, fn x, points ->
        MapSet.put(points, Point.init(x, y))
      end)
    end)
  end

  defp update_active_list(scan_line, active, edge_table) do
    active
    |> Enum.reject(&remove_processed_edges(&1, scan_line))
    |> add_active_edges(scan_line, edge_table)
    |> Enum.sort(&sort_by_x_and_slope(&1, &2))
  end

  defp sort_by_x_and_slope(%EdgeBucket{x: x0},
                           %EdgeBucket{x: x1})
                           when x0 < x1, do: true
  defp sort_by_x_and_slope(%EdgeBucket{x: x0},
                           %EdgeBucket{x: x1})
                           when x1 > x0, do: false
  defp sort_by_x_and_slope(%EdgeBucket{distance_x: dx0, distance_y: dy0},
                           %EdgeBucket{distance_x: dx1, distance_y: dy1}),
                           do: (dx0 / dy0) < (dx1 / dy1)

  defp add_active_edges(active, _scan_line, []), do: Enum.reverse(active)
  defp add_active_edges(active, scan_line, [%EdgeBucket{y_min: y_min}=edge | edge_table]) when scan_line == y_min do
    add_active_edges([edge | active], scan_line, edge_table)
  end
  defp add_active_edges(active, scan_line, [_ | edge_table]) do
    add_active_edges(active, scan_line, edge_table)
  end

  defp remove_processed_edges(%EdgeBucket{y_max: y}, scan_line) when y == scan_line, do: true
  defp remove_processed_edges(_edge_bucket, _scan_line), do: false

  defp create_edge_table(vertices) do
    vertices
    |> Stream.with_index
    |> Stream.map(fn {p0, idx} ->
      p1 = Enum.at(vertices, idx - 1)
      Line.init(p0, p1)
    end)
    |> Stream.map(&line_left_to_right(&1))
    |> Stream.map(&line_to_edge_bucket(&1))
    |> Stream.reject(&horizontal_line?(&1))
    |> Enum.sort(&sort_by_min_y(&1, &2))
  end

  defp line_left_to_right(%Line{origin: %Point{x: x0}=p0, termination: %Point{x: x1}=p1}) when x0 > x1, do: Line.init(p1, p0)
  defp line_left_to_right(line), do: line

  defp line_to_edge_bucket(%Line{origin: p0, termination: p1}) do
    y_max  = if p0.y > p1.y, do: p0.y, else: p1.y
    y_min  = if p0.y < p1.y, do: p0.y, else: p1.y
    init_x = if p0.y < p1.y, do: p0.x, else: p1.x
    sign   = if p1.y - p0.y < 0, do: -1, else: 1
    dx     = abs(p1.x - p0.x)
    dy     = abs(p1.y - p0.y)

    %EdgeBucket{
      y_min:      round(y_min),
      y_max:      round(y_max),
      x:          round(init_x),
      sign:       sign,
      distance_x: round(dx),
      distance_y: round(dy),
      sum:        0
    }
  end

  defp horizontal_line?(%EdgeBucket{distance_y: 0}), do: true
  defp horizontal_line?(_edge_bucket), do: false

  defp sort_by_min_y(%EdgeBucket{y_min: y_min0}, %EdgeBucket{y_min: y_min1}), do: y_min1 > y_min0
end