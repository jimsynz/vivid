defmodule Vivid.Buffer do
  alias Vivid.{Bounds, Buffer, Frame, Point, Rasterize, RGBA}
  defstruct ~w(buffer rows columns)a

  @moduledoc ~S"""
  Used to convert a Frame into a buffer for display.

  You're unlikely to need to use this module directly, instead you will
  likely want to use `Frame.buffer/2` instead.

  Buffer implements the `Enumerable` protocol.

  ## Example

      iex> use Vivid
      ...> box = Box.init(Point.init(1,1), Point.init(18,8))
      ...> Frame.init(20, 10, RGBA.white())
      ...> |> Frame.push(box, RGBA.black())
      ...> |> Buffer.horizontal()
      ...> |> Stream.chunk_every(20)
      ...> |> Stream.map(fn line ->
      ...>   Stream.map(line, fn colour -> RGBA.to_ascii(colour) end)
      ...>   |> Enum.join()
      ...> end)
      ...> |> Enum.join("\n")
      "@@@@@@@@@@@@@@@@@@@@\n" <>
      "@                  @\n" <>
      "@ @@@@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@ @\n" <>
      "@ @@@@@@@@@@@@@@@@ @\n" <>
      "@                  @\n" <>
      "@@@@@@@@@@@@@@@@@@@@"
  """

  @type t :: %Buffer{buffer: [RGBA.t()], rows: integer, columns: integer}

  @doc ~S"""
  Render the buffer horizontally, ie across rows then up columns.

  ## Example

      iex> use Vivid
      ...> Frame.init(5, 5, RGBA.white)
      ...> |> Frame.push(Line.init(Point.init(0, 2), Point.init(5, 2)), RGBA.black)
      ...> |> Buffer.horizontal
      ...> |> to_string
      "@@@@@\n" <>
      "@@@@@\n" <>
      "     \n" <>
      "@@@@@\n" <>
      "@@@@@\n"
  """
  @spec horizontal(Frame.t()) :: Buffer.t()
  def horizontal(%Frame{shapes: shapes, width: w, height: h} = frame) do
    empty_buffer = allocate(frame)
    bounds = Bounds.bounds(frame)

    buffer =
      shapes
      |> Enum.reduce(empty_buffer, &horizontal_reducer(&1, &2, bounds, w))
      |> :array.to_list()

    %Buffer{buffer: buffer, rows: h, columns: w}
  end

  @doc ~S"""
  Render the buffer vertically, ie up columns then across rows.

  ## Example

      iex> use Vivid
      ...> Frame.init(5, 5, RGBA.white)
      ...> |> Frame.push(Line.init(Point.init(0, 2), Point.init(5, 2)), RGBA.black)
      ...> |> Buffer.vertical
      ...> |> to_string
      "@@ @@\n" <>
      "@@ @@\n" <>
      "@@ @@\n" <>
      "@@ @@\n" <>
      "@@ @@\n"
  """
  @spec vertical(Frame.t()) :: Buffer.t()
  def vertical(%Frame{shapes: shapes, width: w, height: h} = frame) do
    bounds = Bounds.bounds(frame)
    empty_buffer = allocate(frame)

    buffer =
      shapes
      |> Enum.reduce(empty_buffer, &vertical_reducer(&1, &2, bounds, h))
      |> :array.to_list()

    %Buffer{buffer: buffer, rows: w, columns: h}
  end

  @doc """
  Returns the number of rows in the buffer.
  """
  @spec rows(t) :: pos_integer
  def rows(%Buffer{rows: r}), do: r

  @doc """
  Returns the number of columns in the buffer.
  """
  @spec columns(t) :: pos_integer
  def columns(%Buffer{columns: c}), do: c

  @doc ~S"""
  Convert the `buffer` into a binary of four byte RGBA pixels.

  Rows are emitted from the top of the buffer downwards, and each row from left
  to right, which is the order image formats expect rather than the bottom-up
  order the buffer is indexed in.

  ## Example

      iex> use Vivid
      ...> Frame.init(2, 2, RGBA.black())
      ...> |> Frame.push(Point.init(0, 0), RGBA.white())
      ...> |> Frame.buffer()
      ...> |> Buffer.to_binary()
      <<0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 255, 255, 0, 0, 0, 255>>
  """
  @spec to_binary(t) :: binary
  def to_binary(%Buffer{buffer: buffer, columns: columns}) do
    buffer
    |> Enum.map(&RGBA.to_binary(&1))
    |> Enum.chunk_every(columns)
    |> Enum.reverse()
    |> IO.iodata_to_binary()
  end

  defp horizontal_reducer({shape, colour}, buffer, bounds, width) do
    shape
    |> Rasterize.rasterize(bounds)
    |> Enum.reduce(buffer, fn %Point{x: x, y: y}, buf ->
      composite(buf, y * width + x, colour)
    end)
  end

  defp vertical_reducer({shape, colour}, buffer, bounds, width) do
    shape
    |> Rasterize.rasterize(bounds)
    |> Enum.reduce(buffer, fn point, buf ->
      %Point{x: x, y: y} = Point.swap_xy(point)
      composite(buf, y * width + x, colour)
    end)
  end

  defp composite(buffer, position, colour),
    do: :array.set(position, RGBA.over(:array.get(position, buffer), colour), buffer)

  defp allocate(%Frame{width: w, height: h, background_colour: bg}),
    do: :array.new(w * h, [{:default, bg}, {:fixed, true}])
end
