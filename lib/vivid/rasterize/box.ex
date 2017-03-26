defimpl Vivid.Rasterize, for: Vivid.Box do
  alias Vivid.{Box, Rasterize, Bounds}

  @moduledoc """
  Rasterizes a box into points.
  """

  @doc """
  Rasterize all points of `box` within `bounds` into a `MapSet`.

  ## Example

      iex> use Vivid
      ...> box = Box.init(Point.init(2,2), Point.init(4,4))
      ...> Rasterize.rasterize(box, Bounds.bounds(box))
      #MapSet<[#Vivid.Point<{2, 2}>, #Vivid.Point<{2, 3}>, #Vivid.Point<{2, 4}>, #Vivid.Point<{3, 2}>, #Vivid.Point<{3, 4}>, #Vivid.Point<{4, 2}>, #Vivid.Point<{4, 3}>, #Vivid.Point<{4, 4}>]>
  """
  @spec rasterize(Box.t, Bounds.t) :: MapSet.t
  def rasterize(box, bounds) do
    box
    |> Box.to_polygon
    |> Rasterize.rasterize(bounds)
  end
end
