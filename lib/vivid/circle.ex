defmodule Vivid.Circle do
  alias Vivid.{Circle, Point, Polygon}
  defstruct ~w(center radius fill)a
  import Vivid.Math

  @moduledoc """
  Represents a circle based on it's center point and radius.
  """
  @opaque t :: %Circle{center: Point.t, radius: number, fill: boolean}

  @doc """
  Creates a circle from a point in 2D space and a radius.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      #Vivid.Circle<[center: #Vivid.Point<{5, 5}>, radius: 4]>
  """
  @spec init(Point.t, number) :: Circle.t
  def init(%Point{} = point, radius)
  when is_number(radius) and radius > 0,
  do: init(point, radius, false)

  @doc false
  @spec init(Point.t, number, boolean) :: Circle.t
  def init(%Point{} = point, radius, fill)
  when is_number(radius) and is_boolean(fill) and radius > 0
  do
    %Circle{
      center: point,
      radius: radius,
      fill:   fill
    }
  end

  @doc """
  Returns the radius of a circle.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      ...> |> Vivid.Circle.radius
      4
  """
  @spec radius(Cricle.t) :: number
  def radius(%Circle{radius: r}), do: r

  @doc """
  Returns the center point of a circle.

  ## Example
      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      ...> |> Vivid.Circle.center
      %Vivid.Point{x: 5, y: 5}
  """
  @spec center(Circle.t) :: Point.t
  def center(%Circle{center: point}), do: point

  @doc """
  Returns the circumference of a circle.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      ...> |> Vivid.Circle.circumference
      25.132741228718345
  """
  @spec circumference(Circle.t) :: number
  def circumference(%Circle{radius: radius}), do: 2 * :math.pi * radius

  @doc ~S"""
  Convert the `circle` into a Polygon.

  We convert a circle into a Polygon whenever we Transform or render it, so
  sometimes it might be worth doing it yourself and specifying how many vertices
  the polygon should have.

  When unspecified `steps` is set to the diameter of the circle rounded to
  the nearest integer.

  ## Examples

      iex> use Vivid
      ...> Circle.init(Point.init(5,5), 5)
      ...> |> Circle.to_polygon
      ...> |> to_string
      "@@@@@@@@@@@@@\n" <>
      "@@@@     @@@@\n" <>
      "@@@ @@@@@ @@@\n" <>
      "@@ @@@@@@@ @@\n" <>
      "@@ @@@@@@@ @@\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@@ @@@@@@@ @@\n" <>
      "@@ @@@@@@@ @@\n" <>
      "@@@ @@@@@ @@@\n" <>
      "@@@@     @@@@\n" <>
      "@@@@@@@@@@@@@\n"
  """
  @spec to_polygon(Circle.t) :: Polygon.t
  def to_polygon(%Circle{radius: radius} = circle), do: to_polygon(circle, round(radius * 2))

  @doc ~S"""
  Convert the `circle` into a Polygon with a specific number of vertices.

  We convert a circle into a Polygon whenever we Transform or render it, so
  sometimes it might be worth doing it yourself and specifying how many vertices
  the polygon should have.

  ## Examples

      iex> use Vivid
      ...> Circle.init(Point.init(5,5), 5)
      ...> |> Circle.to_polygon(3)
      ...> |> to_string
      "@@@@@@@@@@@\n" <>
      "@  @@@@@@@@\n" <>
      "@ @  @@@@@@\n" <>
      "@ @@@  @@@@\n" <>
      "@ @@@@@  @@\n" <>
      "@ @@@@@@@ @\n" <>
      "@ @@@@@  @@\n" <>
      "@ @@@  @@@@\n" <>
      "@ @@ @@@@@@\n" <>
      "@   @@@@@@@\n" <>
      "@ @@@@@@@@@\n" <>
      "@@@@@@@@@@@\n"
  """
  @spec to_polygon(Circle.t, number) :: Polygon.t
  def to_polygon(%Circle{center: center, radius: radius, fill: fill}, steps) do
    h = center |> Point.x
    k = center |> Point.y
    step_degree = 360 / steps

    points = Enum.map(0..steps - 1, fn(step) ->
      theta = step_degree * step
      theta = degrees_to_radians(theta)

      x = h + radius * cos(theta)
      y = k - radius * sin(theta)

      Point.init(x, y)
    end)

    points
    |> Polygon.init(fill)
  end
end
