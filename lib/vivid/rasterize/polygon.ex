defimpl Vivid.Rasterize, for: Vivid.Polygon do
  alias Vivid.{Coverage, Polygon}
  alias Vivid.Polygon.Fill

  defmodule InvalidPolygonError do
    @moduledoc false
    defexception ~w(message)a
  end

  @moduledoc """
  Rasterizes the Polygon into a sequence of points.
  """

  @doc """
  Rasterize all points of `polygon` within `bounds`.

  ## Example

      iex> Vivid.Box.init(Vivid.Point.init(1,1),Vivid.Point.init(3,3))
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      ...> |> Vivid.Coverage.to_points()
      [
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 2, y: 1},
        %Vivid.Point{x: 3, y: 1},
        %Vivid.Point{x: 1, y: 2},
        %Vivid.Point{x: 3, y: 2},
        %Vivid.Point{x: 1, y: 3},
        %Vivid.Point{x: 2, y: 3},
        %Vivid.Point{x: 3, y: 3}
      ]
  """
  @impl true
  def rasterize(%Polygon{vertices: v}, _bounds) when length(v) < 3 do
    raise InvalidPolygonError, "Polygon does not contain enough edges."
  end

  def rasterize(%Polygon{fill: false} = polygon, bounds) do
    polygon_border(polygon, bounds)
  end

  def rasterize(%Polygon{fill: true} = polygon, bounds) do
    polygon
    |> Fill.fill(bounds)
    |> Coverage.union(polygon_border(polygon, bounds))
  end

  defp polygon_border(polygon, bounds) do
    Coverage.from_lines(bounds, Polygon.to_lines(polygon))
  end
end
