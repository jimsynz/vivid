defmodule Vivid.Bounds do
  alias Vivid.{Bounds, Point}
  defstruct ~w(min max)a

  @moduledoc """
  Provides information about the bounds of a box and pixel positions within it.
  """

  @doc """
  Initialise arbitrary bounds.

  ## Example

      iex> Vivid.Bounds.init(0, 0, 5, 5)
      #Vivid.Bounds<[min: #Vivid.Point<{0, 0}>, max: #Vivid.Point<{5, 5}>]>
  """
  def init(x0, y0, x1, y1), do: %Bounds{min: Point.init(x0, y0), max: Point.init(x1, y1)}

  @doc """
  Return the bounding box required to encapsulate the shape.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(10,10), 10)
      ...> |> Vivid.Bounds.bounds
      #Vivid.Bounds<[min: #Vivid.Point<{0.0, 0.0}>, max: #Vivid.Point<{20.0, 20.0}>]>
  """
  def bounds(%Bounds{}=bounds), do: bounds
  def bounds(shape) do
    {min, max} = Vivid.Bounds.Of.bounds(shape)
    %Bounds{min: min, max: max}
  end

  @doc """
  Returns the width of a shape.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(10,10), 10)
      ...> |> Vivid.Bounds.width
      20.0
  """
  def width(%Bounds{min: %Point{x: x0}, max: %Point{x: x1}}), do: abs(x1 - x0)
  def width(shape), do: shape |> bounds |> width

  @doc """
  Returns the height of a shape.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(10,10), 10)
      ...> |> Vivid.Bounds.height
      20.0
  """
  def height(%Bounds{min: %Point{y: y0}, max: %Point{y: y1}}), do: abs(y1 - y0)
  def height(shape), do: shape |> bounds |> height

  @doc """
  Returns the bottom-left point of the bounds.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(10,10), 10)
      ...> |> Vivid.Bounds.min
      #Vivid.Point<{0.0, 0.0}>
  """
  def min(%Bounds{min: min}), do: min
  def min(shape), do: shape |> bounds |> min

  @doc """
  Returns the top-right point of the bounds.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(10,10), 10)
      ...> |> Vivid.Bounds.max
      #Vivid.Point<{20.0, 20.0}>
  """
  def max(%Bounds{max: max}), do: max
  def max(shape), do: shape |> bounds |> max

  @doc """
  Returns the center point of the bounds.

  ## Example

      iex> Vivid.Circle.init(Vivid.Point.init(10,10), 10)
      ...> |> Vivid.Circle.to_polygon
      ...> |> Vivid.Bounds.center_of
      #Vivid.Point<{10.0, 10.0}>
  """
  def center_of(%Bounds{min: %Point{x: x0, y: y0}, max: %Point{x: x1, y: y1}}) do
    x = x0 + (x1 - x0) / 2
    y = y0 + (y1 - y0) / 2
    Point.init(x, y)
  end
  def center_of(shape), do: shape |> bounds |> center_of

  @doc """
  Returns true if the point is within the bounds.

  ## Examples

        iex> Vivid.Bounds.init(0, 0, 10, 10)
        ...> |> Vivid.Bounds.contains?(Vivid.Point.init(0, 0))
        true

        iex> Vivid.Bounds.init(0, 0, 10, 10)
        ...> |> Vivid.Bounds.contains?(Vivid.Point.init(5, 5))
        true

        iex> Vivid.Bounds.init(0, 0, 10, 10)
        ...> |> Vivid.Bounds.contains?(Vivid.Point.init(-1, -1))
        false

        iex> Vivid.Bounds.init(0, 0, 10, 10)
        ...> |> Vivid.Bounds.contains?(Vivid.Point.init(-10, -10))
        false

        iex> Vivid.Bounds.init(0, 0, 10, 10)
        ...> |> Vivid.Bounds.contains?(Vivid.Point.init(10, 10))
        true

        iex> Vivid.Bounds.init(0, 0, 10, 10)
        ...> |> Vivid.Bounds.contains?(Vivid.Point.init(11, 11))
        false
  """
  def contains?(%Bounds{min: %Point{x: x0, y: y0}, max: %Point{x: x1, y: y1}}, %Point{x: x, y: y}) when x0 <= x and x <= x1 and y0 <= y and y <= y1, do: true
  def contains?(_, _), do: false
end
