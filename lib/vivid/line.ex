defmodule Vivid.Line do
  alias Vivid.{Line, Point}
  defstruct ~w(origin termination)a
  import Vivid.Math

  @moduledoc ~S"""
  Represents a line segment between two Points in 2D space.
  """

  @opaque t :: %Line{origin: Point.t, termination: Point.t}

  @doc ~S"""
  Creates a Line.

  ## Examples

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,4))
      %Vivid.Line{origin: %Vivid.Point{x: 1, y: 1}, termination: %Vivid.Point{x: 4, y: 4}}

  """
  @spec init(Point.t, Point.t) :: Line.t
  def init(%Point{}=o, %Point{}=t) do
    %Line{origin: o, termination: t}
  end

  @spec init([Point.t]) :: Line.t
  def init([o,t]) do
    init(o,t)
  end

  @doc ~S"""
  Returns the origin (starting) point of the line segment.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,4)) |> Vivid.Line.origin
      %Vivid.Point{x: 1, y: 1}
  """
  @spec origin(Line.t) :: Point.t
  def origin(%Line{origin: o}), do: o

  @doc ~S"""
  Returns the termination (ending) point of the line segment.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(1,1), Point.init(4,4))
      ...> |> Line.termination
      #Vivid.Point<{4, 4}>
  """
  @spec termination(Line.t) :: Point.t
  def termination(%Line{termination: t}), do: t

  @doc ~S"""
  Calculates the absolute X (horizontal) distance between the origin and termination points.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(14,4)) |> Vivid.Line.width
      13
  """
  @spec width(Line.t) :: number
  def width(%Line{}=line), do: abs(x_distance(line))

  @doc ~S"""
  Calculates the X (horizontal) distance between the origin and termination points.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(14,1), Vivid.Point.init(1,4)) |> Vivid.Line.x_distance
      -13
  """
  @spec x_distance(Line.t) :: number
  def x_distance(%Line{origin: %Point{x: x0}, termination: %Point{x: x1}}), do: x1 - x0

  @doc ~S"""
  Calculates the absolute Y (vertical) distance between the origin and termination points.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,14)) |> Vivid.Line.height
      13
  """
  @spec height(Line.t) :: number
  def height(%Line{}=line), do: abs(y_distance(line))

  @doc ~S"""
  Calculates the Y (vertical) distance between the origin and termination points.

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,14), Vivid.Point.init(4,1)) |> Vivid.Line.y_distance
      -13
  """
  @spec y_distance(Line.t) :: number
  def y_distance(%Line{origin: %Point{y: y0}, termination: %Point{y: y1}}), do: y1 - y0

  @doc ~S"""
  Calculates straight-line distance between the two ends of the line segment using
  Pythagoras' Theorem

  ## Example

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,5)) |> Vivid.Line.length
      5.0
  """
  @spec length(Line.t) :: number
  def length(%Line{}=line) do
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
  @spec on?(Line.t, Point.t) :: boolean
  def on?(%Line{origin: origin, termination: termination}, %Point{}=point) do
    x_distance_point  = point.x  - termination.x
    y_distance_point  = point.y  - termination.y
    x_distance_origin = origin.x - termination.x
    y_distance_origin = origin.y - termination.y
    cross_product     = x_distance_point * y_distance_origin - x_distance_origin * y_distance_point

    cross_product == 0.0
  end

  @doc """
  Find the point on the line where it intersects with the specified `x` axis.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(25, 15), Point.init(5, 2))
      ...> |> Line.x_intersect(10)
      #Vivid.Point<{10, 5.25}>
  """
  @spec x_intersect(Line.t, integer) :: Point.t | nil
  def x_intersect(%Line{origin: %Point{x: x0}=p, termination: %Point{x: x1}}, x) when x == x0 and x == x1, do: p
  def x_intersect(%Line{origin: %Point{x: x0}=p0, termination: %Point{x: x1}=p1}, x) when x0 > x1 do
    x_intersect(%Line{origin: p1, termination: p0}, x)
  end
  def x_intersect(%Line{origin: %Point{x: x0}=p}, x) when x0 == x, do: p
  def x_intersect(%Line{termination: %Point{x: x0}=p}, x) when x0 == x, do: p
  def x_intersect(%Line{origin: %Point{x: x0, y: y0}, termination: %Point{x: x1, y: y1}}, x) when x0 < x and x < x1 do
    rx = (x - x0) / (x1 - x0)
    y  = rx * (y1 - y0) + y0
    Point.init(x, y)
  end
  def x_intersect(_line, _x), do: nil

  @doc """
  Find the point on the line where it intersects with the specified `y` axis.

  ## Example

      iex> use Vivid
      ...> Line.init(Point.init(25, 15), Point.init(5, 2))
      ...> |> Line.y_intersect(10)
      #Vivid.Point<{17.307692307692307, 10}>
  """
  @spec y_intersect(Line.t, integer) :: Point.t | nil
  def y_intersect(%Line{origin: %Point{y: y0}=p, termination: %Point{y: y1}}, y) when y == y0 and y == y1, do: p
  def y_intersect(%Line{origin: %Point{y: y0}=p0, termination: %Point{y: y1}=p1}, y) when y0 > y1 do
    y_intersect(%Line{origin: p1, termination: p0}, y)
  end
  def y_intersect(%Line{origin: %Point{y: y0}=p}, y) when y0 == y, do: p
  def y_intersect(%Line{termination: %Point{y: y0}=p}, y) when y0 == y, do: p
  def y_intersect(%Line{origin: %Point{x: x0, y: y0}, termination: %Point{x: x1, y: y1}}, y) when y0 < y and y < y1 do
    ry = (y - y0) / (y1 - y0)
    x  = ry * (x1 - x0) + x0
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
  @spec horizontal?(Line.t) :: boolean
  def horizontal?(%Line{origin: %Point{y: y0}, termination: %Point{y: y1}}) when y0 == y1, do: true
  def horizontal?(_line), do: false

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
  @spec vertical?(Line.t) :: boolean
  def vertical?(%Line{origin: %Point{x: x0}, termination: %Point{x: x1}}) when x0 == x1, do: true
  def vertical?(_line), do: false
end
