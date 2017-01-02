defimpl Vivid.Rasterize, for: Vivid.Box do
  alias Vivid.{Box, Rasterize}

  @moduledoc """
  Rasterizes a box into points.
  """

  def rasterize(box, bounds) do
    box
    |> Box.to_polygon
    |> Rasterize.rasterize(bounds)
  end
end