defmodule Vivid.Buffer do
  alias Vivid.{Buffer, Frame, Rasterize, Bounds, Point, RGBA}
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
      ...> |> Stream.chunk(20)
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

  @opaque t :: %Buffer{buffer: [RGBA.t], rows: integer, columns: integer}

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
  @spec horizontal(Frame.t) :: [RGBA.t]
  def horizontal(%Frame{shapes: shapes, width: w, height: h} = frame) do
    empty_buffer = allocate(frame)
    bounds       = Bounds.bounds(frame)
    buffer       = Enum.reduce(shapes, empty_buffer, &horizontal_reducer(&1, &2, bounds, w))
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
  @spec vertical(Frame.t) :: [RGBA.t]
  def vertical(%Frame{shapes: shapes, width: w, height: h} = frame) do
    bounds       = Bounds.bounds(frame)
    empty_buffer = allocate(frame)
    buffer       = Enum.reduce(shapes, empty_buffer, &vertical_reducer(&1, &2, bounds, h))

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

  defp horizontal_reducer({shape, colour}, buffer, bounds, width) do
    points = Rasterize.rasterize(shape, bounds)
    Enum.reduce(points, buffer, fn(%Point{x: x, y: y}, buf) ->
      pos = (y * width) + x
      existing = Enum.at(buf, pos)
      List.replace_at(buf, pos, RGBA.over(existing, colour))
    end)
  end

  defp vertical_reducer({shape, colour}, buffer, bounds, width) do
    points = Rasterize.rasterize(shape, bounds)
    Enum.reduce(points, buffer, fn(point, buf) ->
      point = Point.swap_xy(point)
      pos = (point.y * width) + point.x
      existing = Enum.at(buf, pos)
      List.replace_at(buf, pos, RGBA.over(existing, colour))
    end)
  end

  defp allocate(%Frame{width: w, height: h, background_colour: bg}), do: generate_buffer([], w * h, bg)

  defp generate_buffer(buffer, 0, _colour), do: buffer
  defp generate_buffer(buffer, i, colour), do: generate_buffer([colour | buffer], i - 1, colour)
end
