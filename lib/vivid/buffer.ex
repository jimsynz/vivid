defmodule Vivid.Buffer do
  alias Vivid.{Bounds, Buffer, Frame, Point, Rasterize, RGBA, Transformable}
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
  def horizontal(%Frame{shapes: shapes, width: w, height: h, samples: samples} = frame) do
    empty_buffer = allocate(frame)
    bounds = Bounds.bounds(frame)

    buffer =
      shapes
      |> Enum.reduce(empty_buffer, &horizontal_reducer(&1, &2, bounds, w, samples))
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
  def vertical(%Frame{shapes: shapes, width: w, height: h, samples: samples} = frame) do
    bounds = Bounds.bounds(frame)
    empty_buffer = allocate(frame)

    buffer =
      shapes
      |> Enum.reduce(empty_buffer, &vertical_reducer(&1, &2, bounds, h, samples))
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

  defp horizontal_reducer({shape, colour}, buffer, bounds, width, samples) do
    shape
    |> coverage(bounds, samples)
    |> Enum.reduce(buffer, fn {{x, y}, coverage}, buf ->
      composite(buf, y * width + x, colour, coverage)
    end)
  end

  defp vertical_reducer({shape, colour}, buffer, bounds, width, samples) do
    shape
    |> coverage(bounds, samples)
    |> Enum.reduce(buffer, fn {{x, y}, coverage}, buf ->
      composite(buf, x * width + y, colour, coverage)
    end)
  end

  defp coverage(shape, bounds, 1) do
    shape
    |> Rasterize.rasterize(bounds)
    |> Enum.map(fn %Point{x: x, y: y} -> {{x, y}, 1} end)
  end

  defp coverage(shape, bounds, samples) do
    per_pixel = samples * samples

    shape
    |> Transformable.transform(&Point.init(Point.x(&1) * samples, Point.y(&1) * samples))
    |> Rasterize.rasterize(magnify(bounds, samples))
    |> Enum.reduce(%{}, fn %Point{x: x, y: y}, counts ->
      Map.update(counts, {div(x, samples), div(y, samples)}, 1, &(&1 + 1))
    end)
    |> Enum.map(fn {pixel, covered} -> {pixel, covered / per_pixel} end)
  end

  defp magnify(bounds, samples) do
    min = Bounds.min(bounds)
    max = Bounds.max(bounds)

    Bounds.init(
      Point.x(min) * samples,
      Point.y(min) * samples,
      (Point.x(max) + 1) * samples - 1,
      (Point.y(max) + 1) * samples - 1
    )
  end

  defp composite(buffer, position, colour, 1),
    do: :array.set(position, RGBA.over(:array.get(position, buffer), colour), buffer)

  defp composite(buffer, position, colour, coverage) do
    faded =
      RGBA.init(
        RGBA.red(colour),
        RGBA.green(colour),
        RGBA.blue(colour),
        RGBA.alpha(colour) * coverage
      )

    :array.set(position, RGBA.over(:array.get(position, buffer), faded), buffer)
  end

  defp allocate(%Frame{width: w, height: h, background_colour: bg}),
    do: :array.new(w * h, [{:default, bg}, {:fixed, true}])
end
