defimpl Vivid.Rasterize, for: Vivid.Polygon do
  alias Vivid.{Polygon, Rasterize, Bounds, SLPFA}
  require Integer

  defmodule InvalidPolygonError do
    @moduledoc false
    defexception ~w(message)a
  end

  @moduledoc """
  Rasterizes the Polygon into a sequence of points.
  """

  @doc """
  Rasterize all points of `polygon` within `bounds` into a `MapSet`.

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
  @spec rasterize(Polygon.t, Bounds.t) :: MapSet.t
  def rasterize(%Polygon{vertices: v}, _bounds) when length(v) < 3 do
    raise InvalidPolygonError, "Polygon does not contain enough edges."
  end

  def rasterize(%Polygon{fill: false} = polygon, bounds) do
    polygon_border(polygon, bounds)
  end

  def rasterize(%Polygon{fill: true} = polygon, bounds) do
    polygon
    |> filled_polygon_inside_area(bounds)
    |> MapSet.union(polygon_border(polygon, bounds))
  end

  defp filled_polygon_inside_area(polygon, bounds) do
    polygon
    |> SLPFA.fill
    |> Enum.filter(&Bounds.contains?(bounds, &1))
    |> Enum.into(MapSet.new)
  end

  defp polygon_border(polygon, bounds) do
    lines = polygon |> Polygon.to_lines

    Enum.reduce(lines, MapSet.new, fn(line, acc) ->
      MapSet.union(acc, Rasterize.rasterize(line, bounds))
    end)
  end
end
