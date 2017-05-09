defprotocol Vivid.Rasterize do
  alias Vivid.Shape
  @moduledoc ~S"""
  The Rasterize protocol is responsible for converting shapes into bitmaps.

  If you're defining your own shape then you need to implement this protocol.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      ...> |> Rasterize.rasterize(Bounds.init(0,0,5,5))
      #MapSet<[#Vivid.Point<{1, 1}>, #Vivid.Point<{1, 2}>, #Vivid.Point<{1, 3}>, #Vivid.Point<{1, 4}>, #Vivid.Point<{2, 1}>, #Vivid.Point<{2, 4}>, #Vivid.Point<{3, 1}>, #Vivid.Point<{3, 4}>, #Vivid.Point<{4, 1}>, #Vivid.Point<{4, 2}>, #Vivid.Point<{4, 3}>, #Vivid.Point<{4, 4}>]>
  """

  @doc """
  Convert a shape into a bitmap.

  Takes a `shape` and returns a `MapSet` of points within `bounds`.
  """
  @spec rasterize(Shape.t, Bounds.t) :: MapSet
  def rasterize(shape, bounds)
end
