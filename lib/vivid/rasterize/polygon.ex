defimpl Vivid.Rasterize, for: Vivid.Polygon do
  alias Vivid.{Polygon, Rasterize}

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
  def rasterize(%Polygon{}=polygon, bounds) do
    lines = polygon |> Polygon.to_lines

    Enum.reduce(lines, MapSet.new, fn(line, acc) ->
      MapSet.union(acc, Rasterize.rasterize(line, bounds))
    end)
    # |> fill(polygon)
  end

  def fill(points, %Polygon{fill: false}), do: points
  def fill(points, %Polygon{fill: true}), do: points
end
