defmodule Vivid.Transform.Point do
  alias Vivid.Point
  import Vivid.Math

  @moduledoc """
  Standard transformations which can be applied to points without
  knowing the details of the geometry.
  """

  @doc """
  Translate a point (ie move it) by adding `x` and `y` to it's coordinates.
  """
  def translate(%Point{x: x0, y: y0}, x, y), do: Point.init(x0 + x, y0 + y)

  @doc """
  Scale a point (ie move it) by multiplying it's distance from the origin point by `x_factor` and `y_factor`.
  The default origin point is `{0, 0}`
  """
  def scale(%Point{}=point, x_factor, y_factor), do: scale(point, x_factor, y_factor, Point.init(0,0))
  def scale(%Point{x: x, y: y}, x_factor, y_factor, %Point{x: xo, y: yo}) do
    x = (x - xo) * x_factor + xo
    y = (y - yo) * y_factor + yo
    Point.init(x, y)
  end

  @doc """
  Rotate a point `degrees` around an origin point.
  """
  def rotate(point, origin, degrees), do: rotate_radians(point, origin, degrees_to_radians(degrees))

  @doc """
  Rotate a point `radians` around an origin point.
  """
  def rotate_radians(%Point{x: x0, y: y0}=p0, %Point{x: x1, y: y1}=p1, radians) do
    x = x0 - x1
    y = y0 - y1

    x = (x * cos(radians)) - (y * sin(radians))
    y = (y * cos(radians)) + (x * sin(radians))

    Point.init(x + x1, y + y1)
  end
end