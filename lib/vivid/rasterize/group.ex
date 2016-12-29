defimpl Vivid.Rasterize, for: Vivid.Group do
  alias Vivid.{Group, Rasterize}

  @moduledoc """
  Rasterizes the Group into a sequence of points.
  """

  @doc """
  Convert Group into a set of points for display.

  ## Example

      iex> path = Vivid.Path.init([Vivid.Point.init(1,1), Vivid.Point.init(1,3), Vivid.Point.init(3,3), Vivid.Point.init(3,1)])
      ...> Vivid.Group.init([path]) |> Vivid.Rasterize.rasterize({0, 0, 3, 3})
      #MapSet<[#Vivid.Point<{1, 1}>, #Vivid.Point<{1, 2}>, #Vivid.Point<{1, 3}>, #Vivid.Point<{2, 3}>, #Vivid.Point<{3, 1}>, #Vivid.Point<{3, 2}>, #Vivid.Point<{3, 3}>]>
  """
  def rasterize(%Group{shapes: shapes}, bounds) do
    Enum.reduce(shapes, MapSet.new, fn(shape, acc) ->
      MapSet.union(acc, Rasterize.rasterize(shape, bounds))
    end)
  end
end
