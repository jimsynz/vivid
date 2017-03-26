defimpl Vivid.Rasterize, for: Vivid.Group do
  alias Vivid.{Group, Rasterize, Bounds}

  @moduledoc """
  Rasterizes the Group into a sequence of points.
  """

  @doc """
  Rasterize all points of `group` within `bounds` into a `MapSet`.

  ## Example

      iex> path = Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,3), Vivid.Point.init(3,3), Vivid.Point.init(3,1)])
      ...> Vivid.Group.init([path]) |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 3, 3))
      #MapSet<[#Vivid.Point<{1, 1}>, #Vivid.Point<{1, 2}>, #Vivid.Point<{1, 3}>, #Vivid.Point<{2, 3}>, #Vivid.Point<{3, 1}>, #Vivid.Point<{3, 2}>, #Vivid.Point<{3, 3}>]>
  """
  @spec rasterize(Group.t, Bounds.t) :: MapSet.t
  def rasterize(%Group{shapes: shapes} = _group, bounds) do
    Enum.reduce(shapes, MapSet.new, fn(shape, acc) ->
      MapSet.union(acc, Rasterize.rasterize(shape, bounds))
    end)
  end
end
