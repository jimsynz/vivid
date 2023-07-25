defimpl Vivid.Rasterize, for: Vivid.Group do
  alias Vivid.{Group, Rasterize}

  @moduledoc """
  Rasterizes the Group into a sequence of points.
  """

  @doc """
  Rasterize all points of `group` within `bounds` into a `MapSet`.

  ## Example

      iex> path = Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,3), Vivid.Point.init(3,3), Vivid.Point.init(3,1)])
      ...> Vivid.Group.init([path]) |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 3, 3))
      MapSet.new([Vivid.Point.init(1, 1), Vivid.Point.init(1, 2), Vivid.Point.init(1, 3), Vivid.Point.init(2, 3), Vivid.Point.init(3, 1), Vivid.Point.init(3, 2), Vivid.Point.init(3, 3)])
  """
  @impl true
  def rasterize(%Group{shapes: shapes} = _group, bounds) do
    Enum.reduce(shapes, MapSet.new(), fn shape, acc ->
      MapSet.union(acc, Rasterize.rasterize(shape, bounds))
    end)
  end
end
