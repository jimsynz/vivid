defprotocol Vivid.Rasterize do
  alias Vivid.{Bounds, Coverage, Shape}

  @moduledoc ~S"""
  The Rasterize protocol is responsible for converting shapes into bitmaps.

  If you're defining your own shape then you need to implement this protocol.

  An implementation returns a `Vivid.Coverage` - a tensor of how much of each
  pixel within the bounds the shape covers - rather than a collection of points,
  so that a shape which can work out all its pixels at once isn't forced to
  enumerate them one at a time. A shape which delegates to others unions their
  coverages with `Coverage.union/2`.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      ...> |> Rasterize.rasterize(Bounds.init(0,0,5,5))
      ...> |> Coverage.to_points()
      [Point.init(1, 1), Point.init(2, 1), Point.init(3, 1), Point.init(4, 1),
       Point.init(1, 2), Point.init(4, 2), Point.init(1, 3), Point.init(4, 3),
       Point.init(1, 4), Point.init(2, 4), Point.init(3, 4), Point.init(4, 4)]
  """

  @doc """
  Convert a shape into a bitmap.

  Takes a `shape` and returns the `Vivid.Coverage` of `bounds` by it.
  """
  @spec rasterize(Shape.t(), Bounds.t()) :: Coverage.t()
  def rasterize(shape, bounds)
end
