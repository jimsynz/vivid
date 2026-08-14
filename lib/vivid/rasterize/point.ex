defimpl Vivid.Rasterize, for: Vivid.Point do
  alias Vivid.{Coverage, Point}

  @moduledoc """
  Rasterize a single point. i.e. do nothing.
  """

  @doc """
  Return the coverage of `bounds` by `point`, which is the one pixel it lands on
  if that pixel is within the bounds.

  ## Example

      iex> Vivid.Rasterize.rasterize(Vivid.Point.init(3,3), Vivid.Bounds.init(0, 0, 3, 3))
      ...> |> Vivid.Coverage.to_points()
      [%Vivid.Point{x: 3, y: 3}]
  """
  @impl true
  def rasterize(%Point{} = point, bounds),
    do: Coverage.from_points(bounds, [point])
end
