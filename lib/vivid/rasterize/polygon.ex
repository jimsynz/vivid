defimpl Vivid.Rasterize, for: Vivid.Polygon do
  alias Vivid.{Polygon, Rasterize, Point, Bounds, Line}
  require Integer

  defmodule InvalidPolygonError do
    @moduledoc false
    defexception ~w(message)a
  end

  @moduledoc """
  Rasterizes the Polygon into a sequence of points.
  """

  @doc """
  Convert polygon into a set of points for display.

  ## Example

      iex> Vivid.Box.init(Vivid.Point.init(1,1),Vivid.Point.init(3,3))
      ...> |> Vivid.Rasterize.rasterize
      MapSet.new([
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 1, y: 2},
        %Vivid.Point{x: 1, y: 3},
        %Vivid.Point{x: 1, y: 3},
        %Vivid.Point{x: 2, y: 3},
        %Vivid.Point{x: 3, y: 1},
        %Vivid.Point{x: 3, y: 2},
        %Vivid.Point{x: 3, y: 3}
      ])
  """
  def rasterize(%Polygon{vertices: v}=_polygon, _bounds) when length(v) < 3 do
    raise InvalidPolygonError, "Polygon does not contain enough edges."
  end

  def rasterize(%Polygon{fill: false}=polygon, bounds) do
    lines = polygon |> Polygon.to_lines

    Enum.reduce(lines, MapSet.new, fn(line, acc) ->
      MapSet.union(acc, Rasterize.rasterize(line, bounds))
    end)
  end

  def rasterize(%Polygon{fill: true}=polygon, bounds) do
    range = polygon
      |> Bounds.bounds
      |> y_range

    lines = polygon
      |> Polygon.to_lines
      |> Enum.reject(&Line.horizontal?(&1))

    points = Enum.reduce(range, MapSet.new, fn y, points ->
      xs = lines
        |> Stream.map(&Line.y_intersect(&1, y))
        |> Stream.reject(&is_nil(&1))
        |> Stream.map(&Point.x(&1))
        |> Stream.map(&round(&1))
        # |> Enum.dedup
        |> Enum.sort

      MapSet.new
      |> reduce_x_fill([], xs, y)
      |> Stream.filter(&Bounds.contains?(bounds, &1))
      |> Enum.into(points)
    end)

    lines
    |> Stream.flat_map(&Enum.to_list(&1))
    |> Stream.map(&Point.round(&1))
    |> Stream.filter(&Bounds.contains?(bounds, &1))
    |> Enum.reduce(points, fn point, points -> MapSet.put(points, point) end)
  end

  defp y_range(bounds) do
    y0 = bounds |> Bounds.min |> Point.y |> round
    y1 = bounds |> Bounds.max |> Point.y |> round
    if y1 > y0, do: y0..y1, else: y1..y0
  end

  defp reduce_x_fill(points, _lhs, [], _y), do: points

  defp reduce_x_fill(points, lhs, rhs, y) when rem(length(lhs), 2) == 1 and rem(length(rhs), 2) == 1 do
    [x0 | _]   = lhs
    [x1 | rhs] = rhs
    points = Enum.reduce(x0..x1, points, fn x, points -> MapSet.put(points, Point.init(x, y)) end)
    reduce_x_fill(points, [x1 | lhs], rhs, y)
  end

  defp reduce_x_fill(points, lhs, [x | rhs], y) do
    reduce_x_fill(points, [x | lhs], rhs, y)
  end
end
