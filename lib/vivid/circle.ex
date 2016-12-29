defmodule Vivid.Circle do
  alias Vivid.{Circle, Point, Polygon}
  defstruct ~w(center radius fill)a
  import :math, only: [pow: 2, sqrt: 1]

  @moduledoc """
  Represents a circle based on it's center point and radius.
  """

  @doc """
  Creates a circle from a point in 2D space and a radius.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      %Vivid.Circle{center: %Vivid.Point{x: 5, y: 5}, radius: 4}
  """
  def init(point, radius), do: init(point, radius, false)
  def init(%Point{}=point, radius, fill)
  when is_number(radius) and is_boolean(fill)
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

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4) |> Vivid.Circle.radius
      4
  """
  def radius(%Circle{radius: r}), do: r

  @doc """
  Returns the center point of a circle.

  ## Example
      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4) |> Vivid.Circle.center
      %Vivid.Point{x: 5, y: 5}
  """
  def center(%Circle{center: point}), do: point

  @doc """
  Returns the circumference of a circle.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4) |> Vivid.Circle.circumference
      25.132741228718345
  """
  def circumference(%Circle{radius: radius}), do: 2 * :math.pi * radius

  def to_polygon(%Circle{center: point, radius: radius, fill: fill}) do
    x_center  = point |> Point.x
    y_center  = point |> Point.y
    r_squared = pow(radius, 2)

    {points0, points1} = Enum.reduce(0-radius..radius, {[], []}, fn (x, {points0, points1}) ->
      y  = sqrt(r_squared - pow(x, 2)) |> round
      x  = x_center + x
      y0 = y_center - y
      y1 = y_center + y
      points0 = [ Point.init(x, y0) | points0 ]
      points1 = [ Point.init(x, y1) | points1 ]
      {points0, points1}
    end)

    points1 = points1 |> Enum.reverse

    points0 ++ points1
   |> Polygon.init(fill)
  end
end