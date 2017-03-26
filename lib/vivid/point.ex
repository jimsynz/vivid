defmodule Vivid.Point do
  alias __MODULE__
  defstruct ~w(x y)a

  @moduledoc ~S"""
  Represents an individual point in (2D) space.
  """

  @opaque t :: %Point{x: number, y: number}

  @doc ~S"""
  Creates a Point using `x` and `y` coordinates.

  ## Examples

      iex> Vivid.Point.init(13, 27)
      %Vivid.Point{x: 13, y: 27}
  """
  @spec init(number, number) :: Point.t
  def init(x, y)
  when is_number(x) and is_number(y)
  do
    %Point{x: x, y: y}
  end

  @doc ~S"""
  Returns the X coordinate of the point.

  ## Examples

      iex> Vivid.Point.init(13, 27) |> Vivid.Point.x
      13
  """
  @spec x(Point.t) :: number
  def x(%Point{x: x}), do: x

  @doc ~S"""
  Returns the Y coordinate of the point.

  ## Examples

      iex> Vivid.Point.init(13, 27) |> Vivid.Point.y
      27
  """
  @spec y(Point.t) :: number
  def y(%Point{y: y}), do: y

  @doc """
  Simple helper to swap X and Y coordinates - used
  when translating the frame buffer to vertical.

  ## Example

      iex> Vivid.Point.init(13, 27)
      ...> |> Vivid.Point.swap_xy
      #Vivid.Point<{27, 13}>
  """
  @spec swap_xy(Point.t) :: Point.t
  def swap_xy(%Point{x: x, y: y}), do: Point.init(y, x)

  @doc """
  Return the vector in x and y between point `a` and point `b`.

  ## Example

      iex> use Vivid
      ...> a = Point.init(10, 10)
      ...> b = Point.init(20, 20)
      ...> Point.vector(a, b)
      {10, 10}
  """
  @spec vector(Point.t, Point.t) :: {number, number}
  def vector(%Point{x: x0, y: y0} = _a, %Point{x: x1, y: y1} = _b) do
    {x1 - x0, y1 - y0}
  end

  @doc """
  Round the coordinates in the point to the nearest integer value.

  ## Example

      iex> Vivid.Point.init(1.23, 4.56)
      ...> |> Vivid.Point.round
      #Vivid.Point<{1, 5}>
  """
  @spec round(Point.t) :: Point.t
  def round(%Point{x: x, y: y}), do: Point.init(Kernel.round(x), Kernel.round(y))
end
