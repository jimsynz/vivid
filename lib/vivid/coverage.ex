defmodule Vivid.Coverage do
  alias Vivid.{Bounds, Coverage, Line, Point}
  defstruct ~w(x_min y_min tensor)a

  @moduledoc ~S"""
  How much of each pixel within some bounds a shape covers.

  This is what `Vivid.Rasterize` returns: a rank 2 tensor of numbers between
  zero and one, one per pixel of the bounds it was rasterised against, indexed
  from the bottom left. `x_min` and `y_min` say which pixel index `{0, 0}` is,
  so a coverage knows where in the plane it sits without carrying the bounds
  struct around.

  Coverages compose with `union/2`, which takes the larger of each pixel, in
  the same way the `MapSet` of points this replaced composed with
  `MapSet.union/2`. A shape which rasterises by delegating to several others -
  a `Path` to its lines, a `Group` to its members - unions their coverages.

  Because a pixel's coverage is a fraction rather than a yes or no, partial
  coverage is representable here rather than only in the frame buffer. The
  supersampling in `Vivid.Buffer` uses that: it rasterises into a magnified
  coverage and `downsample/2`s it back, which is the same arithmetic the
  subpixel histogram used to do a pixel at a time.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(0, 0), Point.init(3, 3))
      ...> |> Rasterize.rasterize(Bounds.init(0, 0, 3, 3))
      ...> |> Coverage.to_points()
      ...> |> Enum.sort_by(&{Point.x(&1), Point.y(&1)})
      [Point.init(0, 0), Point.init(1, 1), Point.init(2, 2), Point.init(3, 3)]
  """

  @type t :: %Coverage{x_min: integer, y_min: integer, tensor: Nx.Tensor.t()}

  @doc """
  An empty coverage of `bounds` - every pixel uncovered.

  ## Example

      iex> Vivid.Bounds.init(0, 0, 3, 1)
      ...> |> Vivid.Coverage.empty()
      ...> |> Vivid.Coverage.shape()
      {2, 4}
  """
  @spec empty(Bounds.t()) :: t
  def empty(bounds) do
    {rows, columns} = dimensions(bounds)
    from_tensor(bounds, Nx.broadcast(Nx.tensor(0.0, type: {:f, 64}), {rows, columns}))
  end

  @doc """
  A coverage with no pixels at all.

  Distinct from `empty/1`, which has the pixels of some bounds and covers none
  of them. This is what nothing at all rasterises to when there are no bounds to
  say how big nothing is.

  ## Example

      iex> Vivid.Coverage.none() |> Vivid.Coverage.to_points()
      []
  """
  @spec none() :: t
  def none,
    do: %Coverage{
      x_min: 0,
      y_min: 0,
      tensor: Nx.broadcast(Nx.tensor(0.0, type: {:f, 64}), {1, 1})
    }

  @doc """
  A coverage of `bounds` whose pixels are `tensor`.

  The tensor must be shaped `{rows, columns}` to match the bounds, as
  `empty/1` would allocate it.

  ## Example

      iex> Vivid.Coverage.from_tensor(Vivid.Bounds.init(0, 0, 1, 1), Nx.tensor([[0, 1], [1, 0]]))
      ...> |> Vivid.Coverage.to_points()
      ...> |> Enum.sort_by(&{Vivid.Point.x(&1), Vivid.Point.y(&1)})
      [Vivid.Point.init(0, 1), Vivid.Point.init(1, 0)]
  """
  @spec from_tensor(Bounds.t(), Nx.Tensor.t()) :: t
  def from_tensor(bounds, tensor) do
    %Point{x: x_min, y: y_min} = Bounds.min(bounds)

    %Coverage{
      x_min: ceil(x_min),
      y_min: ceil(y_min),
      tensor: Nx.as_type(tensor, {:f, 64})
    }
  end

  @doc ~S"""
  A coverage of `bounds` in which `points` are fully covered and everything
  else is not.

  Points outside the bounds are discarded, and coordinates are rounded, so this
  is how a shape which knows its pixels as coordinates rather than as a grid
  hands them over.

  ## Example

      iex> use Vivid
      ...> Coverage.from_points(Bounds.init(0, 0, 4, 4), [Point.init(1, 1), Point.init(9, 9)])
      ...> |> Coverage.to_points()
      [Point.init(1, 1)]
  """
  @spec from_points(Bounds.t(), Enumerable.t()) :: t
  def from_points(bounds, points) do
    case Enum.map(points, fn %Point{x: x, y: y} -> {round(x), round(y)} end) do
      [] ->
        empty(bounds)

      pixels ->
        {xs, ys} = Enum.unzip(pixels)
        from_pixels(bounds, Nx.tensor(xs), Nx.tensor(ys))
    end
  end

  @doc ~S"""
  A coverage of `bounds` in which the pixels at the coordinates in the `xs` and
  `ys` tensors are fully covered.

  The tensors are of pixel coordinates, already rounded, and are paired
  elementwise. Coordinates outside the bounds are discarded without leaving the
  tensor, which is what this exists for - a shape which has computed its pixels
  as tensors shouldn't have to come back to the list world to place them.

  ## Example

      iex> use Vivid
      ...> Coverage.from_pixels(Bounds.init(0, 0, 4, 4), Nx.tensor([0, 2, 7]), Nx.tensor([0, 2, 7]))
      ...> |> Coverage.to_points()
      [Point.init(0, 0), Point.init(2, 2)]
  """
  @spec from_pixels(Bounds.t(), Nx.Tensor.t(), Nx.Tensor.t()) :: t
  def from_pixels(bounds, xs, ys) do
    {rows, columns} = dimensions(bounds)
    %Point{x: x_min, y: y_min} = Bounds.min(bounds)

    from_tensor(bounds, place(xs, ys, ceil(x_min), ceil(y_min), rows, columns))
  end

  @doc ~S"""
  A coverage of `bounds` by every pixel every line in `lines` passes through.

  This is how a shape built out of line segments rasterises its outline. Going
  through the segments together rather than one at a time is the point: a
  coverage is the size of its bounds, so unioning one per segment would cost the
  area of the frame for every segment of the shape.

  ## Example

      iex> use Vivid
      ...> Coverage.from_lines(Bounds.init(0, 0, 2, 2), [
      ...>   Line.init(Point.init(0, 0), Point.init(2, 0)),
      ...>   Line.init(Point.init(0, 2), Point.init(2, 2))
      ...> ])
      ...> |> Coverage.to_points()
      [Point.init(0, 0), Point.init(1, 0), Point.init(2, 0),
       Point.init(0, 2), Point.init(1, 2), Point.init(2, 2)]
  """
  @spec from_lines(Bounds.t(), [Line.t()]) :: t
  def from_lines(bounds, []), do: empty(bounds)

  def from_lines(bounds, lines) do
    {xs, ys} = Line.pixels(lines)

    from_pixels(bounds, xs, ys)
  end

  @doc """
  The `{rows, columns}` shape of the coverage's tensor.

  ## Example

      iex> Vivid.Bounds.init(0, 0, 9, 4)
      ...> |> Vivid.Coverage.empty()
      ...> |> Vivid.Coverage.shape()
      {5, 10}
  """
  @spec shape(t) :: {non_neg_integer, non_neg_integer}
  def shape(%Coverage{tensor: tensor}), do: Nx.shape(tensor)

  @doc """
  The coverage's pixels as a tensor, indexed `{row, column}` from the bottom
  left.

  ## Example

      iex> Vivid.Point.init(1, 0)
      ...> |> Vivid.Rasterize.rasterize(Vivid.Bounds.init(0, 0, 1, 0))
      ...> |> Vivid.Coverage.tensor()
      ...> |> Nx.to_flat_list()
      [0.0, 1.0]
  """
  @spec tensor(t) :: Nx.Tensor.t()
  def tensor(%Coverage{tensor: tensor}), do: tensor

  @doc ~S"""
  Combine two coverages of the same bounds, taking the greater coverage of each
  pixel.

  ## Example

      iex> use Vivid
      ...> bounds = Bounds.init(0, 0, 2, 0)
      ...> Coverage.union(
      ...>   Coverage.from_points(bounds, [Point.init(0, 0)]),
      ...>   Coverage.from_points(bounds, [Point.init(2, 0)])
      ...> )
      ...> |> Coverage.to_points()
      [Point.init(0, 0), Point.init(2, 0)]
  """
  @spec union(t, t) :: t
  def union(%Coverage{tensor: a} = coverage, %Coverage{tensor: b}),
    do: %{coverage | tensor: Nx.max(a, b)}

  @doc ~S"""
  Reduce a coverage rasterised at `samples` pixels per pixel on each axis back
  to one pixel per pixel, each pixel covered by the fraction of its subpixels
  which were.

  ## Example

  A half covered pixel, sampled four times over.

      iex> use Vivid
      ...> Bounds.init(0, 0, 1, 1)
      ...> |> Coverage.from_points([Point.init(0, 0), Point.init(1, 0)])
      ...> |> Coverage.downsample(2)
      ...> |> Coverage.tensor()
      ...> |> Nx.to_flat_list()
      [0.5]
  """
  @spec downsample(t, pos_integer) :: t
  def downsample(%Coverage{x_min: x_min, y_min: y_min, tensor: tensor}, samples) do
    {rows, columns} = Nx.shape(tensor)

    tensor =
      tensor
      |> Nx.reshape({div(rows, samples), samples, div(columns, samples), samples})
      |> Nx.mean(axes: [1, 3])

    %Coverage{x_min: div(x_min, samples), y_min: div(y_min, samples), tensor: tensor}
  end

  @doc ~S"""
  Whether `point`'s pixel is covered at all.

  ## Example

      iex> use Vivid
      ...> coverage = Coverage.from_points(Bounds.init(0, 0, 4, 4), [Point.init(1, 2)])
      ...> {Coverage.covers?(coverage, Point.init(1, 2)), Coverage.covers?(coverage, Point.init(2, 1))}
      {true, false}
  """
  @spec covers?(t, Point.t()) :: boolean
  def covers?(%Coverage{x_min: x_min, y_min: y_min, tensor: tensor}, %Point{x: x, y: y}) do
    {rows, columns} = Nx.shape(tensor)
    row = round(y) - y_min
    column = round(x) - x_min

    row >= 0 and row < rows and column >= 0 and column < columns and
      Nx.to_number(tensor[row][column]) > 0
  end

  @doc ~S"""
  The points of the coverage which are covered at all, as a list.

  Useful for inspecting a rasterisation and for handing pixels to something
  which wants them as shapes, but it throws away partial coverage - a pixel is
  either in the list or it isn't.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(0, 0), Point.init(1, 1))
      ...> |> Rasterize.rasterize(Bounds.init(0, 0, 1, 1))
      ...> |> Coverage.to_points()
      [Point.init(0, 0), Point.init(1, 0), Point.init(0, 1), Point.init(1, 1)]
  """
  @spec to_points(t) :: [Point.t()]
  def to_points(%Coverage{x_min: x_min, y_min: y_min, tensor: tensor}) do
    {_rows, columns} = Nx.shape(tensor)

    tensor
    |> Nx.to_flat_list()
    |> Enum.with_index()
    |> Enum.filter(fn {coverage, _index} -> coverage > 0 end)
    |> Enum.map(fn {_coverage, index} ->
      Point.init(rem(index, columns) + x_min, div(index, columns) + y_min)
    end)
  end

  defp dimensions(bounds) do
    %Point{x: x_min, y: y_min} = Bounds.min(bounds)
    %Point{x: x_max, y: y_max} = Bounds.max(bounds)

    {max(floor(y_max) - ceil(y_min) + 1, 0), max(floor(x_max) - ceil(x_min) + 1, 0)}
  end

  # Out of bounds coordinates are written to a scratch cell past the end of the
  # buffer, which is then sliced off, so that discarding them costs a select
  # rather than a trip back through a list.
  defp place(_xs, _ys, _x_min, _y_min, rows, columns) when rows == 0 or columns == 0,
    do: Nx.broadcast(Nx.tensor(0.0, type: {:f, 64}), {rows, columns})

  defp place(xs, ys, x_min, y_min, rows, columns) do
    pixels = rows * columns
    row = Nx.subtract(ys, y_min)
    column = Nx.subtract(xs, x_min)

    within =
      [
        Nx.greater_equal(row, 0),
        Nx.less(row, rows),
        Nx.greater_equal(column, 0),
        Nx.less(column, columns)
      ]
      |> Enum.reduce(&Nx.logical_and/2)

    indices =
      within
      |> Nx.select(Nx.add(Nx.multiply(row, columns), column), pixels)
      |> Nx.new_axis(-1)

    Nx.broadcast(Nx.tensor(0.0, type: {:f, 64}), {pixels + 1})
    |> Nx.indexed_put(indices, Nx.broadcast(Nx.tensor(1.0, type: {:f, 64}), Nx.shape(row)))
    |> Nx.slice([0], [pixels])
    |> Nx.reshape({rows, columns})
  end
end
