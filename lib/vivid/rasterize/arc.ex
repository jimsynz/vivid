defimpl Vivid.Rasterize, for: Vivid.Arc do
  alias Vivid.{Rasterize, Arc}

  @moduledoc """
  Rasterizes an Arc.
  """

  @doc ~S"""
  Rasterize all points of `arc` within `bounds` into a `MapSet`.

  ## Example

      iex> Vivid.Arc.init(Vivid.Point.init(5,5), 5, 270, 90, 3)
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 5, 5))
      MapSet.new([Vivid.Point.init(0, 5), Vivid.Point.init(1, 3), Vivid.Point.init(1, 4), Vivid.Point.init(2, 2), Vivid.Point.init(3, 1), Vivid.Point.init(4, 1), Vivid.Point.init(5, 0)])

  """
  @impl true
  def rasterize(arc, bounds) do
    arc
    |> Arc.to_path()
    |> Rasterize.rasterize(bounds)
  end
end
