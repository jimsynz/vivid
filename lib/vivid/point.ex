defmodule Vivid.Point do
  alias __MODULE__
  defstruct ~w(x y)a

  @moduledoc ~S"""
  Represents an individual point in (2D) space.
  """

  @doc ~S"""
  Creates a Point.

  ## Examples

      iex> Vivid.Point.init(13, 27)
      %Vivid.Point{x: 13, y: 27}
  """
  def init(x, y) do
    %Point{x: x, y: y}
  end

  @doc ~S"""
  Returns the X coordinate of the point.

  ## Examples

      iex> Vivid.Point.init(13, 27) |> Vivid.Point.x
      13
  """
  def x(%Point{x: x}), do: x

  @doc ~S"""
  Returns the Y coordinate of the point.

  ## Examples

      iex> Vivid.Point.init(13, 27) |> Vivid.Point.y
      27
  """
  def y(%Point{y: y}), do: y

  @doc """
  Simple helper to swap X and Y coordinates - used
  when translating the frame buffer to vertical.
  """
  def swap_xy(%Point{x: x, y: y}), do: Point.init(y, x)

  @doc """
  Return the vector in `x` and `y` between point `a` and point `b`.
  """
  def vector(%Point{x: x0, y: y0}, %Point{x: x1, y: y1}) do
    {x1 - x0, y1 - y0}
  end

  @doc """
  Round the coordinates in the point to the nearest integer value.

  ## Example

      iex> Vivid.Point.init(1.23, 4.56)
      ...> |> Vivid.Point.round
      #Vivid.Point<{1, 5}>
  """
  def round(%Point{x: x, y: y}), do: Point.init(Kernel.round(x), Kernel.round(y))
end