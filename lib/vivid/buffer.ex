defmodule Vivid.Buffer do
  alias Vivid.{Bounds, Buffer, Coverage, Frame, Point, RGBA, Rasterize, Transformable}
  defstruct ~w(buffer rows columns)a

  @moduledoc ~S"""
  Used to convert a Frame into a buffer for display.

  You're unlikely to need to use this module directly, instead you will
  likely want to use `Frame.buffer/2` instead.

  The buffer is a `{rows, columns, 4}` tensor of red, green, blue and alpha,
  which is the same four numbers a `Vivid.RGBA` holds, so every pixel of the
  frame is composited in one operation per shape rather than one per pixel. The
  colours only become structs again on the way out, through `Enumerable`.

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

  @type t :: %Buffer{buffer: Nx.Tensor.t(), rows: integer, columns: integer}

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
  def horizontal(%Frame{width: w, height: h} = frame),
    do: %Buffer{buffer: composite(frame), rows: h, columns: w}

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
  def vertical(%Frame{width: w, height: h} = frame) do
    buffer =
      frame
      |> composite()
      |> Nx.transpose(axes: [1, 0, 2])

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
  The buffer's pixels as `Vivid.RGBA` colours, in the buffer's own bottom-up
  order.

  The channels come back out of the tensor as floats whatever went in, so a
  colour built from integers is not the same term when it comes back.

  ## Example

      iex> use Vivid
      ...> Frame.init(1, 2, RGBA.black())
      ...> |> Frame.buffer()
      ...> |> Buffer.colours()
      [RGBA.init(0.0, 0.0, 0.0, 1.0), RGBA.init(0.0, 0.0, 0.0, 1.0)]
  """
  @spec colours(t) :: [RGBA.t()]
  def colours(%Buffer{buffer: buffer}) do
    buffer
    |> Nx.reshape({:auto, 4})
    |> Nx.to_list()
    |> Enum.map(fn [r, g, b, a] -> RGBA.init(clamp(r), clamp(g), clamp(b), clamp(a)) end)
  end

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
  def to_binary(%Buffer{buffer: buffer}) do
    buffer
    |> Nx.reverse(axes: [0])
    |> Nx.multiply(255)
    |> Nx.round()
    |> Nx.as_type({:u, 8})
    |> Nx.to_binary()
  end

  @doc false
  @spec luminance(t) :: Nx.Tensor.t()
  def luminance(%Buffer{buffer: buffer}) do
    alpha = buffer[[.., .., 3..3]]

    buffer[[.., .., 0..2]]
    |> Nx.multiply(alpha)
    |> Nx.pow(2.2)
    |> Nx.multiply(Nx.tensor([0.2128, 0.7150, 0.0722], type: {:f, 64}))
    |> Nx.sum(axes: [-1])
  end

  defp composite(%Frame{shapes: shapes, samples: samples} = frame) do
    bounds = Bounds.bounds(frame)

    Enum.reduce(shapes, background(frame), fn {shape, colour}, pixels ->
      over(pixels, colour, coverage(shape, bounds, samples))
    end)
  end

  # `RGBA.over/2` keeps its colours unpremultiplied and premultiplies them as it
  # blends, which is what this does too, one whole frame at a time. A source
  # alpha of zero has to be selected around rather than blended, because
  # blending it would premultiply the destination's colour into itself.
  defp over(pixels, colour, coverage) do
    source_alpha = Nx.multiply(coverage, RGBA.alpha(colour)) |> Nx.new_axis(-1)
    destination_alpha = pixels[[.., .., 3..3]]

    source =
      Nx.tensor([RGBA.red(colour), RGBA.green(colour), RGBA.blue(colour)], type: {:f, 64})

    colours =
      source
      |> Nx.multiply(source_alpha)
      |> Nx.add(
        pixels[[.., .., 0..2]]
        |> Nx.multiply(destination_alpha)
        |> Nx.multiply(Nx.subtract(1, source_alpha))
      )

    alpha =
      source_alpha
      |> Nx.multiply(Nx.subtract(1, destination_alpha))
      |> Nx.add(destination_alpha)

    Nx.select(
      source_alpha |> Nx.greater(0) |> Nx.broadcast(Nx.shape(pixels)),
      Nx.concatenate([colours, alpha], axis: -1),
      pixels
    )
  end

  defp coverage(shape, bounds, 1) do
    shape
    |> Rasterize.rasterize(bounds)
    |> Coverage.tensor()
  end

  defp coverage(shape, bounds, samples) do
    shape
    |> Transformable.transform(&Point.init(Point.x(&1) * samples, Point.y(&1) * samples))
    |> Rasterize.rasterize(magnify(bounds, samples))
    |> Coverage.downsample(samples)
    |> Coverage.tensor()
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

  defp background(%Frame{width: w, height: h, background_colour: colour}) do
    colour
    |> then(&[RGBA.red(&1), RGBA.green(&1), RGBA.blue(&1), RGBA.alpha(&1)])
    |> Nx.tensor(type: {:f, 64})
    |> Nx.broadcast({h, w, 4})
  end

  defp clamp(value) when value < 0, do: 0
  defp clamp(value) when value > 1, do: 1
  defp clamp(value), do: value
end
