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
end