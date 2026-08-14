defmodule Vivid.Bitmap do
  alias Vivid.{Bitmap, Point}
  defstruct ~w(pixels origin size)a

  @moduledoc ~S"""
  A grid of lit cells - a bitmap - as a shape.

  Each lit cell covers a square of side `size`, so a cell at `{column, row}`
  covers everything from `origin + {column, row} * size` up to, but not
  including, the next cell along. Covering an area rather than marking a position
  is the whole point: it means a bitmap drawn at twice its size comes out as
  blocks of four pixels rather than as the same pixels twice as far apart, and it
  means sampling a frame more than once per pixel still finds a cell wherever it
  looks inside one.

  Cells are half-open deliberately. A pixel of a frame is covered by the sample
  taken at its own coordinates, so a cell running from `2` up to `3` lights pixel
  `2` and leaves pixel `3` to the next cell along, whatever size it is drawn at.

  ## Example

  A cross, drawn at one pixel per cell and then at three.

      iex> use Vivid
      ...> cross = Bitmap.init([{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}])
      ...> Frame.init(3, 3, RGBA.white())
      ...> |> Frame.push(cross, RGBA.black())
      ...> |> to_string()
      "@ @\n" <>
      "   \n" <>
      "@ @\n"

      iex> use Vivid
      ...> cross = Bitmap.init([{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}], Point.init(0, 0), 3)
      ...> Frame.init(9, 9, RGBA.white())
      ...> |> Frame.push(cross, RGBA.black())
      ...> |> to_string()
      "@@@   @@@\n" <>
      "@@@   @@@\n" <>
      "@@@   @@@\n" <>
      "         \n" <>
      "         \n" <>
      "         \n" <>
      "@@@   @@@\n" <>
      "@@@   @@@\n" <>
      "@@@   @@@\n"
  """

  @type t :: %Bitmap{pixels: [{integer, integer}], origin: Point.t(), size: number}

  @doc """
  Initialize a bitmap of lit cells, one unit square each, from the origin.

  ## Example

      iex> Vivid.Bitmap.init([{0, 0}, {1, 1}])
      ...> |> Vivid.Bitmap.size()
      1
  """
  @spec init([{integer, integer}]) :: Bitmap.t()
  def init(pixels), do: init(pixels, Point.init(0, 0), 1)

  @doc """
  Initialize a bitmap of lit cells of side `size`, starting at `origin`.

  ## Example

      iex> Vivid.Bitmap.init([{0, 0}], Vivid.Point.init(4, 4), 2)
      ...> |> Vivid.Bitmap.origin()
      Vivid.Point.init(4, 4)
  """
  @spec init([{integer, integer}], Point.t(), number) :: Bitmap.t()
  def init(pixels, %Point{} = origin, size) when is_list(pixels) and is_number(size),
    do: %Bitmap{pixels: pixels, origin: origin, size: size}

  @doc """
  Returns the lit cells of `bitmap`.

  ## Example

      iex> Vivid.Bitmap.init([{0, 0}, {1, 1}])
      ...> |> Vivid.Bitmap.pixels()
      [{0, 0}, {1, 1}]
  """
  @spec pixels(Bitmap.t()) :: [{integer, integer}]
  def pixels(%Bitmap{pixels: pixels} = _bitmap), do: pixels

  @doc """
  Returns the point `bitmap`'s cells are measured from.

  ## Example

      iex> Vivid.Bitmap.init([{0, 0}])
      ...> |> Vivid.Bitmap.origin()
      Vivid.Point.init(0, 0)
  """
  @spec origin(Bitmap.t()) :: Point.t()
  def origin(%Bitmap{origin: origin} = _bitmap), do: origin

  @doc """
  Returns the length of a side of one of `bitmap`'s cells.

  ## Example

      iex> Vivid.Bitmap.init([{0, 0}], Vivid.Point.init(0, 0), 2.5)
      ...> |> Vivid.Bitmap.size()
      2.5
  """
  @spec size(Bitmap.t()) :: number
  def size(%Bitmap{size: size} = _bitmap), do: size

  @doc """
  Returns the range of frame coordinates covered by cell index `index` along one
  axis, given the `origin` and `size` of the bitmap.

  ## Example

  The third cell of a bitmap with cells three wide covers nine, ten and eleven.

      iex> Vivid.Bitmap.cell_span(0, 3, 3)
      9..11
  """
  @spec cell_span(number, integer, number) :: Range.t()
  def cell_span(origin, index, size),
    do: ceil(origin + index * size)..(ceil(origin + (index + 1) * size) - 1)//1
end
