defimpl Vivid.Rasterize, for: Vivid.Group do
  alias Vivid.{Group, Rasterize}

  @moduledoc """
  Rasterizes the Group into a sequence of points.
  """

  @doc """
  Convert Group into a set of points for display.

  ## Example

      iex> path = Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,3), Vivid.Point.init(3,3), Vivid.Point.init(3,1)])
      ...> Vivid.Group.init([path])
      ...> |> Vivid.Rasterize.rasterize
      MapSet.new([
        %Vivid.Point{x: 1, y: 1},
        %Vivid.Point{x: 1, y: 2},
        %Vivid.Point{x: 1, y: 3},
        %Vivid.Point{x: 2, y: 3},
        %Vivid.Point{x: 3, y: 1},
        %Vivid.Point{x: 3, y: 2},
        %Vivid.Point{x: 3, y: 3}
      ])
  """
  def rasterize(%Group{shapes: shapes}) do
    Enum.reduce(shapes, MapSet.new, fn(shape, acc) ->
      MapSet.union(acc, Rasterize.rasterize(shape))
    end)
  end
end
