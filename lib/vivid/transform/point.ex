defmodule Vivid.Transform.Point do
  alias Vivid.Point
  import :math, only: [cos: 1, sin: 1]

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
    x = (x - xo) * x_factor + xo |> round
    y = (y - yo) * y_factor + yo |> round
    Point.init(x, y)
  end

  @doc """
  Rotate a point `degrees` around an origin point.
  """
  def rotate(%Point{x: x0, y: y0}, %Point{x: x1, y: y1}, radians) do
    x = x1 - x0
    y = y1 - y0

    x = (x * cos(radians)) - (y * sin(radians)) |> round
    y = (x * sin(radians)) + (y * cos(radians)) |> round

    Point.init(x + x0, y + y0)
  end
end