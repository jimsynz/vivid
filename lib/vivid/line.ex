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

      iex> Vivid.Line.init(Vivid.Point.init(1,1), Vivid.Point.init(4,4)) |> Vivid.Line.termination
      %Vivid.Point{x: 4, y: 4}
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

end