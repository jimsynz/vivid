defimpl Vivid.Rasterize, for: Vivid.Polygon do
  alias Vivid.{Polygon, Rasterize, Point}
  require Integer

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
  def rasterize(%Polygon{fill: fill}=polygon, bounds) do
    lines = polygon |> Polygon.to_lines

    Enum.reduce(lines, MapSet.new, fn(line, acc) ->
      MapSet.union(acc, Rasterize.rasterize(line, bounds))
    end)
    |> fill(fill)
  end

  def fill(points, false), do: points
  def fill(points, true) do
    points
    |> Enum.sort_by(&Point.y(&1))
    |> Enum.chunk_by(&Point.y(&1))
    |> Enum.reduce(points, fn [p | _]=row, points ->
      row = Enum.map(row, &Point.x(&1))
      reduce_x_fill(points, [], row, Point.y(p))
    end)
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
