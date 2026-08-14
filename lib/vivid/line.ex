defmodule Vivid.Line do
  alias Vivid.{Line, Point}
  defstruct ~w(origin termination)a
  import Vivid.Math

  @moduledoc ~S"""
  Represents a line segment between two Points in 2D space.

  ## Example

    iex> use Vivid
    ...> Line.init(Point.init(0,0), Point.init(5,5))
    ...> |> to_string()
    "@@@@@@@@\n" <>
    "@@@@@@ @\n" <>
    "@@@@@ @@\n" <>
    "@@@@ @@@\n" <>
    "@@@ @@@@\n" <>
    "@@ @@@@@\n" <>
    "@ @@@@@@\n" <>
    "@@@@@@@@\n"
  """

  @type t :: %Line{origin: Point.t(), termination: Point.t()}

  @doc ~S"""
  Create a Line given an `origin` and `termination` point.

  ## Examples

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,4))
      %Vivid.Line{origin: %Vivid.Point{x: 1, y: 1}, termination: %Vivid.Point{x: 4, y: 4}}

  """
  @spec init(Point.t(), Point.t()) :: Line.t()
  def init(%Point{} = origin, %Point{} = termination) do
    %Line{origin: origin, termination: termination}
  end

  @doc """
  Create a `Line` from a two-element list of points.
  """
  @spec init([Point.t()]) :: Line.t()
  def init([o, t]) do
    init(o, t)
  end

  @doc ~S"""
  Returns the origin (starting) point of the line segment.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,4)) |> Vivid.Line.origin
      %Vivid.Point{x: 1, y: 1}
  """
  @spec origin(Line.t()) :: Point.t()
  def origin(%Line{origin: o}), do: o

  @doc ~S"""
  Returns the termination (ending) point of the line segment.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(1,1), Point.init(4,4))
      ...> |> Line.termination
      Vivid.Point.init(4, 4)
  """
  @spec termination(Line.t()) :: Point.t()
  def termination(%Line{termination: t}), do: t

  @doc ~S"""
  Calculates the absolute X (horizontal) distance between the origin and termination points.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(14,4)) |> Vivid.Line.width
      13
  """
  @spec width(Line.t()) :: number
  def width(%Line{} = line), do: abs(x_distance(line))

  @doc ~S"""
  Calculates the X (horizontal) distance between the origin and termination points.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(14,1), Vivid.Point.init(1,4)) |> Vivid.Line.x_distance
      -13
  """
  @spec x_distance(Line.t()) :: number
  def x_distance(%Line{origin: %Point{x: x0}, termination: %Point{x: x1}}), do: x1 - x0

  @doc ~S"""
  Calculates the absolute Y (vertical) distance between the origin and termination points.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,14)) |> Vivid.Line.height
      13
  """
  @spec height(Line.t()) :: number
  def height(%Line{} = line), do: abs(y_distance(line))

  @doc ~S"""
  Calculates the Y (vertical) distance between the origin and termination points.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,14), Vivid.Point.init(4,1)) |> Vivid.Line.y_distance
      -13
  """
  @spec y_distance(Line.t()) :: number
  def y_distance(%Line{origin: %Point{y: y0}, termination: %Point{y: y1}}), do: y1 - y0

  @doc ~S"""
  Calculates straight-line distance between the two ends of the line segment using
  Pythagoras' Theorem

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,5)) |> Vivid.Line.length
      5.0
  """
  @spec length(Line.t()) :: number
  def length(%Line{} = line) do
    dx2 = line |> width |> pow(2)
    dy2 = line |> height |> pow(2)
    sqrt(dx2 + dy2)
  end

  @doc """
  Returns whether a point is on the line.

  ## Example

    iex> use Vivid
    ...> Line.init(Point.init(1,1), Point.init(3,1))
    ...> |> Line.on?(Point.init(2,1))
    true

    iex> use Vivid
    ...> Line.init(Point.init(1,1), Point.init(3,1))
    ...> |> Line.on?(Point.init(2,2))
    false
  """
  @spec on?(Line.t(), Point.t()) :: boolean
  def on?(%Line{origin: origin, termination: termination}, %Point{} = point) do
    x_distance_point = point.x - termination.x
    y_distance_point = point.y - termination.y
    x_distance_origin = origin.x - termination.x
    y_distance_origin = origin.y - termination.y
    cross_product = x_distance_point * y_distance_origin - x_distance_origin * y_distance_point

    cross_product == 0.0
  end

  @doc """
  Find the point on the line where it intersects with the specified `x` axis.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(25, 15), Point.init(5, 2))
      ...> |> Line.x_intersect(10)
      Vivid.Point.init(10, 5.25)
  """
  @spec x_intersect(Line.t(), integer) :: Point.t() | nil
  def x_intersect(%Line{origin: %Point{x: x0} = p, termination: %Point{x: x1}}, x)
      when x == x0 and x == x1,
      do: p

  def x_intersect(%Line{origin: %Point{x: x0} = p0, termination: %Point{x: x1} = p1}, x)
      when x0 > x1 do
    x_intersect(%Line{origin: p1, termination: p0}, x)
  end

  def x_intersect(%Line{origin: %Point{x: x0} = p}, x) when x0 == x, do: p
  def x_intersect(%Line{termination: %Point{x: x0} = p}, x) when x0 == x, do: p

  def x_intersect(%Line{origin: %Point{x: x0, y: y0}, termination: %Point{x: x1, y: y1}}, x)
      when x0 < x and x < x1 do
    rx = (x - x0) / (x1 - x0)
    y = rx * (y1 - y0) + y0
    Point.init(x, y)
  end

  def x_intersect(_line, _x), do: nil

  @doc """
  Find the point on the line where it intersects with the specified `y` axis.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(25, 15), Point.init(5, 2))
      ...> |> Line.y_intersect(10)
      Vivid.Point.init(17.307692307692307, 10)
  """
  @spec y_intersect(Line.t(), integer) :: Point.t() | nil
  def y_intersect(%Line{origin: %Point{y: y0} = p, termination: %Point{y: y1}}, y)
      when y == y0 and y == y1,
      do: p

  def y_intersect(%Line{origin: %Point{y: y0} = p0, termination: %Point{y: y1} = p1}, y)
      when y0 > y1 do
    y_intersect(%Line{origin: p1, termination: p0}, y)
  end

  def y_intersect(%Line{origin: %Point{y: y0} = p}, y) when y0 == y, do: p
  def y_intersect(%Line{termination: %Point{y: y0} = p}, y) when y0 == y, do: p

  def y_intersect(%Line{origin: %Point{x: x0, y: y0}, termination: %Point{x: x1, y: y1}}, y)
      when y0 < y and y < y1 do
    ry = (y - y0) / (y1 - y0)
    x = ry * (x1 - x0) + x0
    Point.init(x, y)
  end

  def y_intersect(_line, _y), do: nil

  @doc """
  Returns true if a line is horizontal.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(10,10), Point.init(20,10))
      ...> |> Line.horizontal?
      true

      iex> use Vivid
      ...> Line.init(Point.init(10,10), Point.init(20,11))
      ...> |> Line.horizontal?
      false
  """
  @spec horizontal?(Line.t()) :: boolean
  def horizontal?(%Line{origin: %Point{y: y0}, termination: %Point{y: y1}}) when y0 == y1,
    do: true

  def horizontal?(_line), do: false

  @doc ~S"""
  The pixel coordinates every line in `lines` passes through, as a pair of
  tensors of `x` and `y`.

  Rasterising a shape made of line segments is a matter of placing these in a
  `Vivid.Coverage`, and doing it for every segment at once is the point: a
  coverage is the size of its bounds, so unioning one per segment would cost the
  whole frame per segment rather than the length of the segment.

  Every segment is stepped over the same parameter, as far as the longest of
  them needs, and the steps past the end of a shorter one are pushed out of any
  possible bounds so that placing them discards them.

  ## Example

      iex> use Vivid
      ...> {xs, ys} = Line.pixels([Line.init(Point.init(0, 0), Point.init(2, 2))])
      ...> {Nx.to_flat_list(xs), Nx.to_flat_list(ys)}
      {[0, 1, 2], [0, 1, 2]}
  """
  @spec pixels([Line.t(), ...]) :: {Nx.Tensor.t(), Nx.Tensor.t()}
  def pixels([_ | _] = lines) do
    steps =
      Enum.map(lines, fn line ->
        %Point{x: x0, y: y0} = line |> origin() |> Point.round()
        %Point{x: x1, y: y1} = line |> termination() |> Point.round()
        {x0, y0, x1, y1, max(abs(x1 - x0), abs(y1 - y0))}
      end)

    longest = steps |> Enum.map(&elem(&1, 4)) |> Enum.max()
    along = Nx.iota({1, longest + 1}, type: {:f, 64})

    within =
      steps
      |> Enum.map(&[elem(&1, 4)])
      |> Nx.tensor(type: {:f, 64})
      |> then(&Nx.less_equal(along, &1))

    {
      interpolate(along, within, steps, &elem(&1, 0), &elem(&1, 2)),
      interpolate(along, within, steps, &elem(&1, 1), &elem(&1, 3))
    }
  end

  @doc """
  Returns true if a line is vertical.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(10,10), Point.init(10,20))
      ...> |> Line.vertical?
      true

      iex> use Vivid
      ...> Line.init(Point.init(10,10), Point.init(11,20))
      ...> |> Line.vertical?
      false
  """
  @spec vertical?(Line.t()) :: boolean
  def vertical?(%Line{origin: %Point{x: x0}, termination: %Point{x: x1}}) when x0 == x1, do: true
  def vertical?(_line), do: false

  # Far enough outside any bounds a caller could ask about that the steps a
  # short segment doesn't take are discarded when they're placed.
  @beyond_any_bounds -1_000_000_000

  defp interpolate(along, within, steps, from, to) do
    starts = steps |> Enum.map(&[from.(&1) * 1.0]) |> Nx.tensor(type: {:f, 64})

    increments =
      steps
      |> Enum.map(fn
        {_, _, _, _, 0} -> [0.0]
        step -> [(to.(step) - from.(step)) / elem(step, 4)]
      end)
      |> Nx.tensor(type: {:f, 64})

    along
    |> Nx.multiply(increments)
    |> Nx.add(starts)
    |> round_half_away()
    |> Nx.as_type({:s, 64})
    |> then(&Nx.select(within, &1, @beyond_any_bounds))
    |> Nx.reshape({:auto})
  end
end
