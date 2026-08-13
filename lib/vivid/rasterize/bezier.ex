defimpl Vivid.Rasterize, for: Vivid.Bezier do
  alias Vivid.{Bezier, Rasterize}

  @moduledoc """
  Rasterizes a Bézier curve.
  """

  @doc ~S"""
  Rasterize all points of `bezier` within `bounds` into a `MapSet`.

  ## Example

      iex> Vivid.Bezier.init([Vivid.Point.init(0,0), Vivid.Point.init(5,10), Vivid.Point.init(10,0)], 4)
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 5, 5))
      MapSet.new([Vivid.Point.init(0, 0), Vivid.Point.init(1, 1), Vivid.Point.init(2, 2), Vivid.Point.init(2, 3), Vivid.Point.init(3, 4), Vivid.Point.init(4, 5), Vivid.Point.init(5, 5)])

  """
  @impl true
  def rasterize(bezier, bounds) do
    bezier
    |> Bezier.to_path()
    |> Rasterize.rasterize(bounds)
  end
end
