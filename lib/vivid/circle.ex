defmodule Vivid.Circle do
  alias Vivid.{Circle, Point, Polygon}
  defstruct ~w(center radius fill)a
  import Vivid.Math

  @moduledoc """
  Represents a circle based on it's center point and radius.
  """

  @doc """
  Creates a circle from a point in 2D space and a radius.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      #Vivid.Circle<[center: #Vivid.Point<{5, 5}>, radius: 4]>
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

  def to_polygon(%Circle{radius: radius}=circle), do: to_polygon(circle, round(radius * 2))
  def to_polygon(%Circle{center: center, radius: radius, fill: fill}, steps) do
    h = center |> Point.x
    k = center |> Point.y
    step_degree = 360 / steps

    Enum.map(0..steps - 1, fn(step) ->
      theta = step_degree * step
      theta = degrees_to_radians(theta)

      x = h + radius * cos(theta)
      y = k - radius * sin(theta)

      Point.init(x, y)
    end)
    |> Polygon.init(fill)
  end
end