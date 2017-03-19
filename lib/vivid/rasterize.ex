defprotocol Vivid.Rasterize do
  alias Vivid.Shape
  @moduledoc """
  The Rasterize protocol is responsible for converting shapes into bitmaps.

  If you're defining your own shape then you need to implement this protocol.
  """

  @doc """
  Convert a shape into a bitmap.

  Takes a `shape` and returns a `MapSet` of points within `bounds`.
  """
  @spec rasterize(Shape.t, Bounds.t) :: MapSet
  def rasterize(shape, bounds)
end
