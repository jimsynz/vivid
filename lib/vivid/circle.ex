defmodule Vivid.Circle do
  alias Vivid.{Circle, Point}
  defstruct ~w(center radius)a

  @moduledoc """
  Represents a circle based on it's center point and radius.
  """

  @doc """
  Creates a circle from a point in 2D space and a radius.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(5,5), 4)
      %Vivid.Circle{center: %Vivid.Point{x: 5, y: 5}, radius: 4}
  """
  def init(%Point{}=point, radius) when is_number(radius) do
    %Circle{
      center: point,
      radius: radius
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
end