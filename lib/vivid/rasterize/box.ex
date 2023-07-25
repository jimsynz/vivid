defimpl Vivid.Rasterize, for: Vivid.Box do
  alias Vivid.{Box, Rasterize}

  @moduledoc """
  Rasterizes a box into points.
  """

  @doc """
  Rasterize all points of `box` within `bounds` into a `MapSet`.

  ## Example

      iex> use Vivid
      ...> box = Box.init(Point.init(2,2), Point.init(4,4))
      ...> Rasterize.rasterize(box, Bounds.bounds(box))
      MapSet.new([Vivid.Point.init(2, 2), Vivid.Point.init(2, 3), Vivid.Point.init(2, 4), Vivid.Point.init(3, 2), Vivid.Point.init(3, 4), Vivid.Point.init(4, 2), Vivid.Point.init(4, 3), Vivid.Point.init(4, 4)])
  """
  @impl true
  def rasterize(box, bounds) do
    box
    |> Box.to_polygon()
    |> Rasterize.rasterize(bounds)
  end
end
