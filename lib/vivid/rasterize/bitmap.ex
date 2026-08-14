defimpl Vivid.Rasterize, for: Vivid.Bitmap do
  alias Vivid.{Bitmap, Bounds, Coverage, Point}

  @moduledoc """
  Rasterizes a Bitmap.

  A cell covers a half open span on each axis, so which pixels it lights is a
  comparison of the grid's coordinates against the cell's edges. Both axes are
  compared for every cell at once, and the two results multiplied together, so
  the whole bitmap lands in the grid as a single matrix product rather than a
  loop over cells and a nested loop over the pixels of each.
  """

  @doc ~S"""
  Rasterize all points of `bitmap` within `bounds`.

  Each lit cell covers whole frame pixels directly, without being filled or
  outlined like a polygon would be, which is what keeps a cell exactly one pixel
  at one unit per cell instead of spreading into its neighbours.

  ## Example

      iex> Vivid.Bitmap.init([{1, 1}])
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      ...> |> Vivid.Coverage.to_points()
      [Vivid.Point.init(1, 1)]

  At two units per cell the same cell covers four pixels.

      iex> Vivid.Bitmap.init([{1, 1}], Vivid.Point.init(0, 0), 2)
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 4, 4))
      ...> |> Vivid.Coverage.to_points()
      [
        Vivid.Point.init(2, 2), Vivid.Point.init(3, 2),
        Vivid.Point.init(2, 3), Vivid.Point.init(3, 3)
      ]
  """
  @impl true
  def rasterize(%Bitmap{pixels: []}, bounds), do: Coverage.empty(bounds)

  def rasterize(%Bitmap{pixels: pixels, origin: origin, size: size}, bounds) do
    %Point{x: x_min, y: y_min} = Bounds.min(bounds)
    %Point{x: x_max, y: y_max} = Bounds.max(bounds)
    {columns, rows} = Enum.unzip(pixels)

    lit =
      Nx.dot(
        Nx.transpose(cells_over(rows, Point.y(origin), size, y_min, y_max)),
        cells_over(columns, Point.x(origin), size, x_min, x_max)
      )

    Coverage.from_tensor(bounds, Nx.min(lit, 1))
  end

  defp cells_over(indices, origin, size, low, high) do
    indices = Nx.tensor(indices) |> Nx.new_axis(-1)
    coordinates = Nx.iota({1, max(floor(high) - ceil(low) + 1, 0)}) |> Nx.add(ceil(low))

    starts = Nx.ceil(Nx.add(Nx.multiply(indices, size), origin))
    ends = Nx.ceil(Nx.add(Nx.multiply(Nx.add(indices, 1), size), origin))

    Nx.greater_equal(coordinates, starts)
    |> Nx.logical_and(Nx.less(coordinates, ends))
    |> Nx.as_type({:f, 64})
  end
end
