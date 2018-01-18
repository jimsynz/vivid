defmodule Vivid.Box do
  alias Vivid.{Box, Point, Polygon, Bounds, Shape}
  defstruct ~w(bottom_left top_right fill)a

  @moduledoc ~S"""
  Short-hand for creating rectangle polygons.

  This module doesn't have very much logic other than knowing how to
  turn itself into a Polygon.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(5,10), Point.init(15,20))
      ...> |> to_string()
      "@@@@@@@@@@@@@\n" <>
      "@           @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@ @@@@@@@@@ @\n" <>
      "@           @\n" <>
      "@@@@@@@@@@@@@\n"
  """

  @opaque t :: Box.t()

  @doc """
  Initialize an unfilled Box from it's bottom left and top right points.

  * `bottom_left` - the bottom left `Point` of the box.
  * `top_right` - the top right `Point` of the box.

  ## Examples

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      #Vivid.Box<[bottom_left: #Vivid.Point<{1, 1}>, top_right: #Vivid.Point<{4, 4}>]>
  """
  @spec init(Point.t(), Point.t()) :: Box.t()
  def init(%Point{} = bottom_left, %Point{} = top_right), do: init(bottom_left, top_right, false)

  @doc """
  Initialize a Box from it's bottom left and top right points and whether it's filled.

  * `bottom_left` - the bottom left `Point` of the box.
  * `top_right` - the top right `Point` of the box.
  * `fill` - whether or not the box should be filled.

  ## Examples

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      #Vivid.Box<[bottom_left: #Vivid.Point<{1, 1}>, top_right: #Vivid.Point<{4, 4}>]>
  """
  @spec init(Point.t(), Point.t(), boolean) :: Box.t()
  def init(%Point{} = bottom_left, %Point{} = top_right, fill) when is_boolean(fill),
    do: %Box{bottom_left: bottom_left, top_right: top_right, fill: fill}

  @doc """
  Initialize a box from the bounds of an arbitrary shape.

  ## Examples

      iex> use Vivid
      ...> Circle.init(Point.init(5,5), 5)
      ...> |> Box.init_from_bounds
      #Vivid.Box<[bottom_left: #Vivid.Point<{0.0, 0.2447174185242318}>, top_right: #Vivid.Point<{10.0, 9.755282581475768}>]>
  """
  @spec init_from_bounds(Shape.t(), boolean) :: Box.t()
  def init_from_bounds(shape, fill \\ false) do
    bounds = shape |> Bounds.bounds()
    min = bounds |> Bounds.min()
    max = bounds |> Bounds.max()
    init(min, max, fill)
  end

  @doc """
  Return the bottom left corner of the box.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      ...> |> Box.bottom_left
      #Vivid.Point<{1, 1}>
  """
  @spec bottom_left(Box.t()) :: Point.t()
  def bottom_left(%Box{bottom_left: bl}), do: bl

  @doc """
  Return the top left corner of the box.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      ...> |> Box.top_left
      #Vivid.Point<{1, 4}>
  """
  @spec top_left(Box.t()) :: Point.t()
  def top_left(%Box{bottom_left: bl, top_right: tr}), do: Point.init(bl.x, tr.y)

  @doc """
  Return the top right corner of the box.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      ...> |> Box.top_right
      #Vivid.Point<{4, 4}>
  """
  @spec top_right(Box.t()) :: Point.t()
  def top_right(%Box{top_right: tr}), do: tr

  @doc """
  Return the top right corner of the box.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      ...> |> Box.bottom_right
      #Vivid.Point<{4, 1}>
  """
  @spec bottom_right(Box.t()) :: Point.t()
  def bottom_right(%Box{bottom_left: bl, top_right: tr}), do: Point.init(tr.x, bl.y)

  @doc """
  Convert a Box into a Polygon.

  ## Example

      iex> use Vivid
      ...> Box.init(Point.init(1,1), Point.init(4,4))
      ...> |> Box.to_polygon
      #Vivid.Polygon<[#Vivid.Point<{1, 1}>, #Vivid.Point<{1, 4}>, #Vivid.Point<{4, 4}>, #Vivid.Point<{4, 1}>]>
  """
  @spec to_polygon(Box.t()) :: Polygon.t()
  def to_polygon(%Box{fill: fill} = box) do
    Polygon.init(
      [
        bottom_left(box),
        top_left(box),
        top_right(box),
        bottom_right(box)
      ],
      fill
    )
  end
end
