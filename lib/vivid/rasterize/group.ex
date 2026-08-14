defimpl Vivid.Rasterize, for: Vivid.Group do
  alias Vivid.{Coverage, Group, Rasterize}

  @moduledoc """
  Rasterizes the Group into a sequence of points.
  """

  @doc """
  Rasterize all points of `group` within `bounds`, as the union of its members'
  coverage.

  ## Example

      iex> path = Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,3), Vivid.Point.init(3,3), Vivid.Point.init(3,1)])
      ...> Vivid.Group.init([path])
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 3, 3))
      ...> |> Vivid.Coverage.to_points()
      [Vivid.Point.init(1, 1), Vivid.Point.init(3, 1), Vivid.Point.init(1, 2), Vivid.Point.init(3, 2), Vivid.Point.init(1, 3), Vivid.Point.init(2, 3), Vivid.Point.init(3, 3)]
  """
  @impl true
  def rasterize(%Group{shapes: shapes} = _group, bounds) do
    Enum.reduce(shapes, Coverage.empty(bounds), fn shape, coverage ->
      Coverage.union(coverage, Rasterize.rasterize(shape, bounds))
    end)
  end
end
