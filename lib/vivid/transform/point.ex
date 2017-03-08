defmodule Vivid.Transform.Point do
  alias Vivid.Point
  import Vivid.Math

  @moduledoc """
  Standard transformations which can be applied to points without
  knowing the details of the geometry.

  Used extensively by `Transform`, however you can use these functions
  as input to the `Transformable` protocol, should you require.
  """

  @type degrees :: number
  @type radians :: number

  @doc """
  Translate `point` (ie move it) by adding `x` and `y` to it's coordinates.
  """
  @spec translate(Point.t, number, number) :: Point.t
  def translate(%Point{x: x0, y: y0} = _point, x, y), do: Point.init(x0 + x, y0 + y)

  @doc """
  Scale `point` (ie move it) by multiplying it's distance from the `0`, `0` point by `x_factor` and `y_factor`.
  """
  @spec scale(Point, number, number) :: Point.t
  def scale(%Point{} = point, x_factor, y_factor), do: scale(point, x_factor, y_factor, Point.init(0,0))

  @doc """
  Scale `point` (ie move it) by multiplying it's distance from the origin point by `x_factor` and `y_factor`.
  """
  @spec scale(Point, number, number, Point.t) :: Point.t
  def scale(%Point{x: x, y: y} = _point, x_factor, y_factor, %Point{x: xo, y: yo} = _origin) do
    x = (x - xo) * x_factor + xo
    y = (y - yo) * y_factor + yo
    Point.init(x, y)
  end

  @doc """
  Rotate `point` `degrees` around an `origin` point.
  """
  @spec rotate(Point.t, Point.t, degrees) :: Point.t
  def rotate(point, origin, degrees), do: rotate_radians(point, origin, degrees_to_radians(degrees))

  @doc """
  Rotate `point` `radians` around an `origin` point.
  """
  @spec rotate_radians(Point.t, Point.t, radians) :: Point.t
  def rotate_radians(%Point{x: x0, y: y0} = _point, %Point{x: x1, y: y1} = _origin, radians) do
    x = cos(radians) * (x0 - x1) - sin(radians) * (y0 - y1) + x1
    y = sin(radians) * (x0 - x1) + cos(radians) * (y0 - y1) + y1
    Point.init(x,y)
  end
end
