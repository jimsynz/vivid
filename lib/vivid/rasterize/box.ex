defimpl Vivid.Rasterize, for: Vivid.Box do
  alias Vivid.{Box, Rasterize, Bounds}

  @moduledoc """
  Rasterizes a box into points.
  """

  @spec rasterize(Box.t, Bounds.t) :: MapSet.t
  def rasterize(box, bounds) do
    box
    |> Box.to_polygon
    |> Rasterize.rasterize(bounds)
  end
end
